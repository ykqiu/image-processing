# Image-Processing
This project is a pipelined image processing in Verilog aimed at FPGA or ASIC where requirements for real-time processing is needed, and where simplicity and LUT usage are more important than maximising the image processing quality.  
This project is mainly done on Xilinx 7 series (Artix, Kintex) using vidado HLS, but it may also be compatible with other platforms or tools in ASIC/FPGA RTL design.  
The idea with this project is to process the incoming imgae from sensor to enhance image quality or extract key informaion, reducing the complexity and hardware requirement(in contrast to MCU). This project consists of a top module, namely ISP_TOP, which is made up by several sub-modules as follows.  
## sdram_controller
This sub-module is used to control or drive a MICRON sdram chip, to storage image data from sensor, and read the data back to FPGA for future use. By using off-chip sdram, the on-chip memory can be largely saved for other use (ISP, etc).  
The sdram-controller consists of a sdram_ctrl module to interacts with sdram chip, and a fifo-ctrl module to encapsulate the sdram-controller with fifo interface, which is easier to operate.  
### sdram_ctrl
This module is the core module to interact with sdram chip. It is used to issue the wrtie or read commands from FPGA and tranfer these commands to sdram bus command. Also, it need to send a refresh command to sdram every **7.8 ms** in case that data loss in sdram. In addition, the sdram_ctrl is used to arbitrate the commands and check the timing to avoid timing violation. The main features of sdram_ctrl are;  
- Arbitrate refresh, write and read command with different priority.
- Send a controlled burst length starting with an activate command and ending with an auto-precharge command.
- Control the write and read channel, including DQ and DQM.
- Follow the timing requirement by sdram chip and enhance transport efficiency.
### fifo_ctrl
This module serves as an interface to connect other module with sdram_ctrl. It encapsulates the sdram_ctrl with an user-friendly fifo interface and a controlled threshold of data number. Besides, it issues requests and sends acknowledges to sdram_ctrl to smooth data tranfer. It supports:
- True dual-port asynchronous fifo interface to cope with data from different clock domain. such as sensor and display domain.
- Controlled data number threshold: send write requests to sdram_ctrl when data number exceeds the threshold, and read requests to when data number is lower than the setting threshold.
- Ping-pong opration switch to make sure the single frame will be read or wirte to a fixed memory space (different bank), to avoid wrong frame.
## vga_controller
The VGA display has the advantages of low cost, simple structure and flexible application. The vga_controller is to control the VGA display panel with a **640*480** resolution. It consists of a VGA_CTRL module to drive the display with appropriate timing parameter, and a HDMI adpater to be compatible with high resolution HDMI display.
## ISP_TOP
This module is the core module to process the incoming data from sdram before sending the processed image to display module. It consists of several sub-modules to meet requirement for different application. Either a solo module or several pipelined modules can be switched on according to the defines. The functionalities of these modules are listed follow.
### RGB2YUV
This module is used to convert the RGB data from sensor to YUV domain, in order to extract the grey information of the image for further processing. The YUV value is calculated by using:
>Y  =      (0.257 * R) + (0.504 * G) + (0.098 * B) + 16  
Cr = V =  (0.439 * R) - (0.368 * G) - (0.071 * B) + 128  
Cb = U = -(0.148 * R) - (0.291 * G) + (0.439 * B) + 128  

The incoming data is 16-bit RGB565 data from sensor, which need to extend the bit width to 8 bits, by copying the least significant bits. Then the extended RGB888 data can be converted to YUV according to above formula.  
When implementing the conversion formula, fraction multiplication or division is avoided by using bit-shift. Also, 3-stage pipline for bit-shift and plus is used to better timing.
### logarithmization
This module is used to enhance image brightness for lower grey-scale pixels. Secifically, according to the formula:  
>s = c log(1+r)  

where c is the scale proportional constant, r is the source gray value, and s is the transformed target gray value. This transformation can enhance the details of the darker parts of an image, so that it can be used to expand the darker pixels in the compressed high-value image.  
The transformation maps a narrow range of low grayscale values of input to a wider range of grayscale values of the output, and vice versa for high input grayscale values.  
To realize the algorithm in hardware, it will cost high resources if the value is calculated by directly using logarithmization opreation. Instead, a LUT is used by calculated the ouput value of 256 grey values in advance, for a given logarithmization formula. Then the LUT is changed to format of log.mif and is loaded in to a rom, which can be read after one cycle when an input grey value is send to its address pin.  
### Histogram  
- Histogram Stretching  
  Histogram stretching is used to adjust the contrast of the image in real time. Histogram stretching refers to stretching the narrow gray-level interval of the image gray-level histogram to both ends to enhance the gray-level contrast of the pixels of the entire image.  
  In this module, linear stretching is used. Linear stretching, also known as grayscale stretching, is a type of linear point operation. It expands the histogram of the image so that it fills the entire grayscale range. Let f(x,y) be the input image, and its minimum gray level A and maximum gray level B are defined as follows:
  >A = min[f(x, y)]  
  B = max[f(x, y)]  
  g(x, y) = 255*[f(x, y)-A]/(B-A)  
  
  The stretching of grayscale images is this project is a pseudo stretching. Instead of using a frame buffer to calculate the **A** and **B** in the current frame,  an approximation is to map from the previous frame when building histogram statistics for the current frame, that is to calculate the **A** and **B**. In fact, all the values of the formula are calculated in the previous frame to stretch the image of current frame, which greatly reduces the design difficulty.  
- Histogram equalization
  Histogram equalization refers to converting an input image into an output image that has approximately the same level at each gray level (ie, the output histogram is uniform) through a certain grayscale mapping. In an equalized image, the pixels will occupy as many gray levels as possible and be evenly distributed. Therefore, such images will have higher contrast and larger dynamic range, the output grey-scale is defined as  
  ![image](https://github.com/ykqiu/Image-Processing/blob/main/docs/1536533-20200323093433495-1853537963.png)  
  As in the case of histogram stretching, pseudo-equalization is used, that is, the image of the previous frame is used for statistics, the frame gap is for grey-scale data accumulated and normalized, and the current frame is normalized for the mapping output.  
  Statistical work cannot be completed at least until the previous frame has "flowed through". This limitation makes it difficult to both count and output the final result in the same frame. Therefore, the previous statistical results must be cached, accumulated, and normalized. Before the next statistics, it is necessary to clear the cached results, accumulated and results, and the normalized results are reserved for the output of the current frame. Two dual-port rams are adopted during the process.  
### Matrix generator  
Convolution operation is important in image processing, especially in various filtering operation, such as median filter, gaussian filter and so on. The core idea of generate a matrix is to buffer a whole line/row into memory, in this case, two fifo. The first fifo stores the incoming data from the first line starts, and read the data out when the second line starts; the second fifo stores the incoming data from the first line starts, and read the data out when the third line starts. The data from the two fifo, as well as the incoming data form a parallel three-row. By delay each row with one and two stage, a 3*3 array is formed.
### Median filter  
The median filter is a non-linear digital filtering technique, the main idea is to do a convolution in a given filter window generated by matrix generator, and to replace the central pixel with the convolution result, in this case, the median of neighboring pixels.  
![image](https://github.com/ykqiu/Image-Processing/blob/main/docs/1536533-20200323103312770-1182590267.png)  
The filter algorithm achienved by following steps:  
- Sort each row of pixels in the window in descending order to get the maximum, middle and minimum values.  
- Compare the minimum value of the three rows, and take the maximum value.  
- Compare the maximum value of the three rows, and take the minimum value.  
- Compare the middle value of the three rows, and take the middle value again.  
- Sort the previous three values again, and the obtained median value is the median value of the window.  
### Gaussian filter  
Gaussian filter can be used to eliminate Gaussian noise. Gaussian filtering is a linear smoothing filter by weighted averaging of the entire image. The value of each pixel is obtained by itself and other pixel values in the neighborhood after weighted averaging.  
![image](https://github.com/ykqiu/Image-Processing/blob/main/docs/1536533-20200323200754303-1161881582.png)  
The gaussian operator is represented as:  
![image](https://github.com/ykqiu/Image-Processing/blob/main/docs/1536533-20200323200031355-1214164222.png)  
### Sobel edge detection  
Sobel operator is a commonly used edge detection template. The algorithm is relatively simple. Technically, the Sobel operator is a discrete difference operator, which is used to calculate the approximation of the gray level of the image brightness function. Using this operator at any point in the image will yield the corresponding grayscale vector or its normal vector. Sobel edge detection is usually directional and can detect only vertical edges or vertical edges or both.
Similarly to Gaussian filter, sobel detection is achienved by implementing a convolution for a given channel. The convolution result represents the virtical or horizontal gradient. When the filter window comes to an edge, the gradient value may become a maximum. After setting an appropriate grey-scale threshold, the image will be filterd as an binary image, which reprents the edge of an image.  
The Sobel operator is represented as  
![image](https://github.com/ykqiu/Image-Processing/blob/main/docs/1536533-20200324143053297-618208439.png)  
### Canny edge detection  
Canny operator is a more accurate edge detection method, compared to sobel detection. Basically, the detection algorithm consists of following four steps:  
- Perform Gaussian filter to require noise. The Gaussian filter mainly smoothes (blurs) the image, and may also increase the width of the edges.
- Perform Sobel operation to calculate gradient value and direction of each pixel.
- Filter the non-maximum pixel, which is the fake edge. To achieve this, each pixel compares its grey-scale value with the neighboring two pixels in the direction of its gradient. Then the pixel will persisit if it is still the maximum point.
![image](https://github.com/ykqiu/Image-Processing/blob/main/docs/v2-bee3a70b859a2a0c49a8ff7f78d03cf2_720w.jpg)  
- Double-threshold filter: it sets two thresholds, maxVal and minVal, respectively. Any pixel greater than maxVal is detected as an edge, and pixel lower than minval is detected as a non-edge. For a pixel in the middle, if it is adjacent to a pixel determined to be an edge, it is determined to be an edge; otherwise, it is a non-edge.  
![image](https://github.com/ykqiu/Image-Processing/blob/main/docs/v2-d55a6eb3add17b3c53c6d68c210cb157_720w.jpg)  

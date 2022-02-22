# Image-Processing
This project is a piplined image processing in Verilog aimed at FPGA or ASIC where requirements for real-time processing is needed, and where simplicity and LUT usage are more important than maximising the image processing quality.  
This project is mainly done on Xilinx 7 series (Artix, Kintex) using vidado HLS, but it may also be compatibel with other platforms or tools in ASIC/FPGA RTL design.  
The idea with this project is to process the incoming imgae from sensor to enhance image quality or extract key informaion, reducing the complexity and hardware requirement(in contrast to MCU). This project consists of a top module, namely ISP_TOP, which is made up by several sub-modules as follows.  
## sdram_controller
This sub-module is a used to control or drive a MICRON sdram chip, to storage image data from sensor, and read the data back to FPGA for future use. By using off-chip sdram, the on-chip memory can be largely saved for other use (ISP, etc).  
The sdram-controller consits of a sdram_ctrl module to interacts with sdram chip, and a fifo-ctrl module to encapsulate the sdram-controller with fifo interface, which is more easy to operate.  
### sdram_ctrl
This module is the core module to interact with sdram chip. It is used to issue the wrtie or read commands from FPGA and tranfer these commands to sdram bus command. Also, it need to send a refresh command to sdram every **7.8 ms** in case that data loss in sdram. In addition, the sdram_ctrl is used to arbitrate the commands and check the timing to avoid timing violation. The main feature of sdram_ctrl is;  
- Arbitrate refresh, write and read command with different priority.
- Send a controlled burst length starting with an activate command and ending with an auto-precharge command.
- Control the write and read channel, including DQ and DQM.
- Follow the timing requirement by sdram chip and enhance transport efficiency.
### fifo_ctrl
This module serves as an interface to connet other module with sdram_ctrl. It encapsulates the sdram_ctrl with an user-friendly fifo interface and a controlled threshold of data number. Besides, it issues requests and send acknoledges to sdram_ctrl to smooth data tranfer. It supports:
- True dual-port asynchronous fifo interface to cope with data from different clock domain. such as sensor and display domain.
- Controlled data number threshold: send write requests to sdram_ctrl when data number exceeds the threshold, and read requests to when data number is lower than the setting threshold.
- Ping-pong opration switch to make sure the single frame will be read or wirte to a fixed memory space (different bank), to avoid wrong frame

## vga_controller
The VGA display has the advantages of low cost, simple structure and flexible application. The vga_controller is a to control the VGA display panel with a **640*480** resolution. It consists of a VGA_CTRL module to drive the display with appropriate timing parameter, and a HDMI adpater to be compatible with high resolution HDMI display.


## ISP_TOP
This module is the core module to process the incoming data from sdram before sending the processed image to display module. It consists of several sub-modules to meet requirement for different application. Either a solo module or sveral piplined modules can be switched on according to the defines. The functionalities of these modules are listed follow.
### RGB2YUV
This module is used to convert the RGB data from sensor to YUV domain, in order to extract the grey information of the image for further processing. The YUV value is calculated by using:
>Y  =      (0.257 * R) + (0.504 * G) + (0.098 * B) + 16  
Cr = V =  (0.439 * R) - (0.368 * G) - (0.071 * B) + 128  
Cb = U = -(0.148 * R) - (0.291 * G) + (0.439 * B) + 128  

The incoming data is 16-bit RGB565 data from sensor, which need to extend the bit width to 8 bits, by copying the least significant bits. Then the extended RGB888 data can be converted to YUV according to above formula.  
When implementing the conversion formula, fraction multiplication or division is avoided by using bit-shift. Also, 3-stage pipline for bit-shift and plus is used to better timing.
### logarithmization
This module is used to implement to enhance imgae brightness for lower grey-scale pixels. Secifically, according to the formula:  
>s = c log(1+r)  

where c is the scale proportional constant, r is the source gray value, and s is the transformed target gray value. This transformation can enhance the details of the darker parts of an image, so that it can be used to expand the darker pixels in the compressed high-value image.  
The transformation maps a narrow range of low grayscale values of input to a wider range of grayscale values of the output, and vice versa for high input grayscale values.  
To realize the algorithm in hardware, it will cost high resources if the value is calculated by directly using logarithmization opreation. Instead, a LUT is used by calculated the ouput value of 256 grey values in advance, for a given logarithmization formula. Then the LUT is changed to format of log.mif and is loaded in to a rom, which can be read after one cycle when an input grey value is send to its address pin.  

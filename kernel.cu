/*
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include "stb_image.h"
#include "stb_image_write.h"
#define CHANNELS 3

__global__
void colorToGreyscaleConversion(unsigned char* Pout, unsigned
	char* Pin, int width, int height) {
	
	int Col = threadIdx.x + blockIdx.x * blockDim.x;
	int Row = threadIdx.y + blockIdx.y * blockDim.y;
	if (Col < width && Row < height) {
		// get 1D coordinate for the grayscale image
		int greyOffset = Row * width + Col;
		// one can think of the RGB image having
		// CHANNEL times columns than the grayscale image
		int rgbOffset = greyOffset * CHANNELS;
		unsigned char r = Pin[rgbOffset]; // red value for pixel
		unsigned char g = Pin[rgbOffset + 1]; // green value for pixel
		unsigned char b = Pin[rgbOffset + 2]; // blue value for pixel
		// perform the rescaling and store it
		// We multiply by floating point constants
		Pout[rgbOffset] = 0.21f * r + 0.71f * g + 0.07f * b;
		Pout[rgbOffset+1] = 0.21f * r + 0.71f * g + 0.07f * b;
		Pout[rgbOffset+2] = 0.21f * r + 0.71f * g + 0.07f * b;
		

	}
}
int main(int arc,char ** argv) {
	int width, height, rgb;
	unsigned char* Pin = stbi_load(argv[1], &width, &height, &rgb, 3);
	//unsigned char* Pout = stbi_load(argv[1], &width, &height, &rgb, 3);
	unsigned char* ptrImageData = NULL;
	unsigned char* ptrImageDataOut = NULL;
	cudaMalloc(&ptrImageData, width * height * CHANNELS);
	cudaMemcpy(ptrImageData, Pin, width * height * CHANNELS, cudaMemcpyHostToDevice);
	cudaMalloc(&ptrImageDataOut, width * height * CHANNELS);
	cudaMemcpy(ptrImageDataOut, Pin, width * height * CHANNELS, cudaMemcpyHostToDevice);
	
	colorToGreyscaleConversion<<<dim3((width / 32), (height / 32)), dim3(32, 32) >>>(ptrImageData, ptrImageDataOut, width, height);

	cudaMemcpy(Pin, ptrImageData, width * height * CHANNELS, cudaMemcpyDeviceToHost);
	std::string NewImageFile = argv[1];
	NewImageFile = NewImageFile.substr(0, NewImageFile.find_last_of('.')) + "toGray.png";
	stbi_write_png(NewImageFile.c_str(), width, height, 3, Pin, 3 * width);
	cudaFree(ptrImageData);
	cudaFree(ptrImageDataOut);
	stbi_image_free(Pin);

}*/
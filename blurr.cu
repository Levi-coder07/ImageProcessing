
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include "stb_image.h"
#include "stb_image_write.h"
#define BLUR_SIZE 11
#define CHANNELS 3

__global__
void colorToBlurConversion(unsigned char* Pout, unsigned
	char* Pin, int width, int height) {

	int Col = blockIdx.x * blockDim.x + threadIdx.x;
	int Row = blockIdx.y * blockDim.y + threadIdx.y;
	if (Col < width && Row < height) {
		int pixValsr = 0;
		int pixValsg = 0;
		int pixValsb = 0;
		int pixels=0;
		int Offset = (Row * width + Col) * CHANNELS;

		for (int blurRow = -BLUR_SIZE; blurRow < BLUR_SIZE + 1; ++blurRow) {
			for (int blurCol = -BLUR_SIZE; blurCol < BLUR_SIZE + 1; ++blurCol) {
				int curRow = Row + blurRow;
				int curCol = Col + blurCol;

			
				if (curRow > -1 && curRow < height && curCol > -1 && curCol < width) {
					int curOffset = (curRow * width + curCol) * CHANNELS;
					pixValsr += Pin[curOffset];
					pixValsg += Pin[curOffset + 1];
					pixValsb += Pin[curOffset + 2];
					pixels++;
				}
			}
		}

		Pout[Offset] = (unsigned char)(pixValsr / pixels);
		Pout[Offset + 1] = (unsigned char)(pixValsg / pixels);
		Pout[Offset + 2] = (unsigned char)(pixValsb / pixels);

	}
}
int main(int arc, char** argv) {
	int width, height, rgb;
	unsigned char* Pin = stbi_load(argv[1], &width, &height, &rgb, 3);
	//unsigned char* Pout = stbi_load(argv[1], &width, &height, &rgb, 3);
	unsigned char* ptrImageData = NULL;
	unsigned char* ptrImageDataOut = NULL;
	cudaMalloc(&ptrImageData, width * height * CHANNELS);
	cudaMemcpy(ptrImageData, Pin, width * height * CHANNELS, cudaMemcpyHostToDevice);
	cudaMalloc(&ptrImageDataOut, width * height * CHANNELS);
	cudaMemcpy(ptrImageDataOut, Pin, width * height * CHANNELS, cudaMemcpyHostToDevice);

	colorToBlurConversion << <dim3((width / 32), (height / 32)), dim3(32, 32) >> > (ptrImageData, ptrImageDataOut, width, height);

	cudaMemcpy(Pin, ptrImageData, width * height * CHANNELS, cudaMemcpyDeviceToHost);
	std::string NewImageFile = argv[1];
	NewImageFile = NewImageFile.substr(0, NewImageFile.find_last_of('.')) + "toBlurr.png";
	stbi_write_png(NewImageFile.c_str(), width, height, 3, Pin, 3 * width);
	cudaFree(ptrImageData);
	cudaFree(ptrImageDataOut);
	stbi_image_free(Pin);

}
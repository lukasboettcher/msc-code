#include <cstddef>
#pragma once

static const char for_test___half_sized_scan_kernel[] = {
0x23, 0x69, 0x66, 0x6e, 0x64, 0x65, 0x66, 0x20, 0x52, 0x55, 0x4e, 0x0a, 0x23, 0x69, 0x6e, 0x63, 0x6c, 0x75, 0x64, 0x65, 
0x20, 0x22, 0x2e, 0x2e, 0x2f, 0x63, 0x6c, 0x69, 0x6f, 0x6e, 0x5f, 0x64, 0x65, 0x66, 0x69, 0x6e, 0x65, 0x73, 0x2e, 0x63, 
0x6c, 0x22, 0x0a, 0x23, 0x64, 0x65, 0x66, 0x69, 0x6e, 0x65, 0x20, 0x47, 0x52, 0x4f, 0x55, 0x50, 0x5f, 0x53, 0x49, 0x5a, 
0x45, 0x20, 0x32, 0x35, 0x36, 0x0a, 0x23, 0x65, 0x6e, 0x64, 0x69, 0x66, 0x0a, 0x2f, 0x2f, 0x2f, 0x2f, 0x20, 0x63, 0x6f, 
0x75, 0x6e, 0x74, 0x20, 0x70, 0x72, 0x65, 0x66, 0x69, 0x78, 0x65, 0x73, 0x20, 0x69, 0x74, 0x73, 0x65, 0x6c, 0x66, 0x20, 
0x6f, 0x6e, 0x20, 0x69, 0x6e, 0x70, 0x75, 0x74, 0x20, 0x61, 0x72, 0x72, 0x61, 0x79, 0x0a, 0x2f, 0x2f, 0x2f, 0x2f, 0x20, 
0x61, 0x6e, 0x64, 0x20, 0x76, 0x65, 0x72, 0x74, 0x69, 0x63, 0x65, 0x73, 0x20, 0x61, 0x73, 0x20, 0x74, 0x68, 0x72, 0x20, 
0x6f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x0a, 0x0a, 0x2f, 0x2f, 0x20, 0x54, 0x4f, 0x44, 0x4f, 0x3a, 0x20, 0x6f, 0x70, 0x74, 
0x69, 0x6d, 0x69, 0x73, 0x65, 0x20, 0x62, 0x61, 0x6e, 0x6b, 0x20, 0x63, 0x6f, 0x6e, 0x66, 0x6c, 0x69, 0x63, 0x74, 0x73, 
0x0a, 0x2f, 0x2f, 0x20, 0x68, 0x74, 0x74, 0x70, 0x73, 0x3a, 0x2f, 0x2f, 0x64, 0x65, 0x76, 0x65, 0x6c, 0x6f, 0x70, 0x65, 
0x72, 0x2e, 0x6e, 0x76, 0x69, 0x64, 0x69, 0x61, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x67, 0x70, 0x75, 0x67, 0x65, 0x6d, 0x73, 
0x2f, 0x67, 0x70, 0x75, 0x67, 0x65, 0x6d, 0x73, 0x33, 0x2f, 0x70, 0x61, 0x72, 0x74, 0x2d, 0x76, 0x69, 0x2d, 0x67, 0x70, 
0x75, 0x2d, 0x63, 0x6f, 0x6d, 0x70, 0x75, 0x74, 0x69, 0x6e, 0x67, 0x2f, 0x63, 0x68, 0x61, 0x70, 0x74, 0x65, 0x72, 0x2d, 
0x33, 0x39, 0x2d, 0x70, 0x61, 0x72, 0x61, 0x6c, 0x6c, 0x65, 0x6c, 0x2d, 0x70, 0x72, 0x65, 0x66, 0x69, 0x78, 0x2d, 0x73, 
0x75, 0x6d, 0x2d, 0x73, 0x63, 0x61, 0x6e, 0x2d, 0x63, 0x75, 0x64, 0x61, 0x0a, 0x5f, 0x5f, 0x6b, 0x65, 0x72, 0x6e, 0x65, 
0x6c, 0x20, 0x76, 0x6f, 0x69, 0x64, 0x20, 0x73, 0x63, 0x61, 0x6e, 0x5f, 0x62, 0x6c, 0x65, 0x6c, 0x6c, 0x6f, 0x63, 0x68, 
0x5f, 0x68, 0x61, 0x6c, 0x66, 0x28, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x5f, 0x5f, 0x67, 0x6c, 0x6f, 
0x62, 0x61, 0x6c, 0x20, 0x75, 0x6e, 0x73, 0x69, 0x67, 0x6e, 0x65, 0x64, 0x20, 0x69, 0x6e, 0x74, 0x20, 0x2a, 0x20, 0x70, 
0x72, 0x65, 0x66, 0x5f, 0x73, 0x75, 0x6d, 0x2c, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x75, 0x6e, 0x73, 
0x69, 0x67, 0x6e, 0x65, 0x64, 0x20, 0x69, 0x6e, 0x74, 0x20, 0x6e, 0x29, 0x0a, 0x7b, 0x0a, 0x0a, 0x20, 0x20, 0x20, 0x20, 
0x5f, 0x5f, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x20, 0x75, 0x69, 0x6e, 0x74, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x47, 0x52, 0x4f, 
0x55, 0x50, 0x5f, 0x53, 0x49, 0x5a, 0x45, 0x20, 0x2a, 0x20, 0x32, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x75, 0x69, 
0x6e, 0x74, 0x20, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x20, 0x3d, 0x20, 0x67, 0x65, 0x74, 0x5f, 0x6c, 0x6f, 
0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x28, 0x30, 0x29, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x75, 0x69, 0x6e, 0x74, 0x20, 
0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5f, 0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 0x5f, 0x68, 0x61, 0x6c, 0x66, 
0x20, 0x3d, 0x20, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x20, 0x2b, 0x20, 0x47, 0x52, 0x4f, 0x55, 0x50, 0x5f, 
0x53, 0x49, 0x5a, 0x45, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x75, 0x69, 0x6e, 0x74, 0x20, 0x62, 0x6c, 0x6f, 0x63, 0x6b, 
0x5f, 0x73, 0x69, 0x7a, 0x65, 0x20, 0x3d, 0x20, 0x67, 0x65, 0x74, 0x5f, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x73, 0x69, 
0x7a, 0x65, 0x28, 0x30, 0x29, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x75, 0x69, 0x6e, 0x74, 0x20, 0x64, 0x6f, 0x75, 0x62, 
0x6c, 0x65, 0x64, 0x5f, 0x62, 0x6c, 0x6f, 0x63, 0x6b, 0x5f, 0x73, 0x69, 0x7a, 0x65, 0x20, 0x3d, 0x20, 0x67, 0x65, 0x74, 
0x5f, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x73, 0x69, 0x7a, 0x65, 0x28, 0x30, 0x29, 0x20, 0x2a, 0x20, 0x32, 0x3b, 0x0a, 
0x0a, 0x20, 0x20, 0x20, 0x20, 0x75, 0x69, 0x6e, 0x74, 0x20, 0x64, 0x70, 0x20, 0x3d, 0x20, 0x31, 0x3b, 0x0a, 0x20, 0x20, 
0x20, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5d, 0x20, 0x3d, 0x20, 0x6c, 0x6f, 
0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x20, 0x3c, 0x20, 0x6e, 0x20, 0x3f, 0x20, 0x70, 0x72, 0x65, 0x66, 0x5f, 0x73, 0x75, 
0x6d, 0x5b, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5d, 0x20, 0x3a, 0x20, 0x30, 0x3b, 0x0a, 0x20, 0x20, 0x20, 
0x20, 0x74, 0x6d, 0x70, 0x5b, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5f, 0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 
0x5f, 0x68, 0x61, 0x6c, 0x66, 0x5d, 0x20, 0x3d, 0x20, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5f, 0x73, 0x65, 
0x63, 0x6f, 0x6e, 0x64, 0x5f, 0x68, 0x61, 0x6c, 0x66, 0x20, 0x3c, 0x20, 0x6e, 0x20, 0x3f, 0x20, 0x70, 0x72, 0x65, 0x66, 
0x5f, 0x73, 0x75, 0x6d, 0x5b, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5f, 0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 
0x5f, 0x68, 0x61, 0x6c, 0x66, 0x5d, 0x20, 0x3a, 0x20, 0x30, 0x3b, 0x0a, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6f, 0x72, 
0x28, 0x75, 0x69, 0x6e, 0x74, 0x20, 0x73, 0x20, 0x3d, 0x20, 0x64, 0x6f, 0x75, 0x62, 0x6c, 0x65, 0x64, 0x5f, 0x62, 0x6c, 
0x6f, 0x63, 0x6b, 0x5f, 0x73, 0x69, 0x7a, 0x65, 0x3e, 0x3e, 0x31, 0x3b, 0x20, 0x73, 0x20, 0x3e, 0x20, 0x31, 0x3b, 0x20, 
0x73, 0x20, 0x3e, 0x3e, 0x3d, 0x20, 0x31, 0x29, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x20, 0x62, 0x61, 0x72, 0x72, 0x69, 0x65, 0x72, 0x28, 0x43, 0x4c, 0x4b, 0x5f, 0x4c, 0x4f, 0x43, 0x41, 0x4c, 
0x5f, 0x4d, 0x45, 0x4d, 0x5f, 0x46, 0x45, 0x4e, 0x43, 0x45, 0x29, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x69, 0x66, 0x28, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x20, 0x3c, 0x20, 0x73, 0x29, 0x0a, 0x20, 0x20, 
0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x75, 0x69, 0x6e, 0x74, 0x20, 0x69, 0x20, 0x3d, 0x20, 0x64, 0x70, 0x2a, 0x28, 0x32, 0x20, 0x2a, 0x20, 0x6c, 0x6f, 0x63, 
0x61, 0x6c, 0x5f, 0x69, 0x64, 0x20, 0x2b, 0x20, 0x31, 0x29, 0x20, 0x2d, 0x20, 0x31, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x75, 0x69, 0x6e, 0x74, 0x20, 0x6a, 0x20, 0x3d, 0x20, 0x64, 0x70, 0x2a, 
0x28, 0x32, 0x20, 0x2a, 0x20, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x20, 0x2b, 0x20, 0x32, 0x29, 0x20, 0x2d, 
0x20, 0x31, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x74, 0x6d, 0x70, 0x5b, 
0x6a, 0x5d, 0x20, 0x2b, 0x3d, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x69, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x7d, 0x0a, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x69, 0x66, 0x28, 0x6c, 0x6f, 0x63, 0x61, 
0x6c, 0x5f, 0x69, 0x64, 0x5f, 0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 0x5f, 0x68, 0x61, 0x6c, 0x66, 0x20, 0x3c, 0x20, 0x73, 
0x29, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x20, 0x20, 0x75, 0x69, 0x6e, 0x74, 0x20, 0x69, 0x20, 0x3d, 0x20, 0x64, 0x70, 0x2a, 0x28, 0x32, 0x20, 0x2a, 
0x20, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5f, 0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 0x5f, 0x68, 0x61, 0x6c, 
0x66, 0x20, 0x2b, 0x20, 0x31, 0x29, 0x20, 0x2d, 0x20, 0x31, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x20, 0x20, 0x75, 0x69, 0x6e, 0x74, 0x20, 0x6a, 0x20, 0x3d, 0x20, 0x64, 0x70, 0x2a, 0x28, 0x32, 0x20, 0x2a, 
0x20, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5f, 0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 0x5f, 0x68, 0x61, 0x6c, 
0x66, 0x20, 0x2b, 0x20, 0x32, 0x29, 0x20, 0x2d, 0x20, 0x31, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x20, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x6a, 0x5d, 0x20, 0x2b, 0x3d, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x69, 0x5d, 
0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x7d, 0x0a, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x64, 0x70, 0x20, 0x3c, 0x3c, 0x3d, 0x20, 0x31, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x7d, 0x0a, 0x0a, 0x20, 0x20, 
0x20, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x64, 0x6f, 0x75, 0x62, 0x6c, 0x65, 0x64, 0x5f, 0x62, 0x6c, 0x6f, 0x63, 0x6b, 0x5f, 
0x73, 0x69, 0x7a, 0x65, 0x20, 0x2d, 0x20, 0x31, 0x5d, 0x20, 0x2b, 0x3d, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x62, 0x6c, 0x6f, 
0x63, 0x6b, 0x5f, 0x73, 0x69, 0x7a, 0x65, 0x20, 0x2d, 0x20, 0x31, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x62, 0x61, 
0x72, 0x72, 0x69, 0x65, 0x72, 0x28, 0x43, 0x4c, 0x4b, 0x5f, 0x4c, 0x4f, 0x43, 0x41, 0x4c, 0x5f, 0x4d, 0x45, 0x4d, 0x5f, 
0x46, 0x45, 0x4e, 0x43, 0x45, 0x29, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x69, 0x66, 0x20, 0x28, 0x6c, 0x6f, 0x63, 0x61, 
0x6c, 0x5f, 0x69, 0x64, 0x20, 0x3d, 0x3d, 0x20, 0x30, 0x29, 0x20, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x70, 0x72, 0x69, 0x6e, 0x74, 0x66, 0x28, 0x22, 0x74, 0x6f, 0x74, 0x61, 0x6c, 0x20, 0x73, 0x75, 0x6d, 0x3a, 0x20, 
0x25, 0x64, 0x5c, 0x6e, 0x22, 0x2c, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x64, 0x6f, 0x75, 0x62, 0x6c, 0x65, 0x64, 0x5f, 0x62, 
0x6c, 0x6f, 0x63, 0x6b, 0x5f, 0x73, 0x69, 0x7a, 0x65, 0x20, 0x2d, 0x20, 0x31, 0x5d, 0x29, 0x3b, 0x0a, 0x20, 0x20, 0x20, 
0x20, 0x7d, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x62, 0x61, 0x72, 0x72, 0x69, 0x65, 0x72, 0x28, 0x43, 0x4c, 0x4b, 0x5f, 0x4c, 
0x4f, 0x43, 0x41, 0x4c, 0x5f, 0x4d, 0x45, 0x4d, 0x5f, 0x46, 0x45, 0x4e, 0x43, 0x45, 0x29, 0x3b, 0x0a, 0x0a, 0x20, 0x20, 
0x20, 0x20, 0x69, 0x66, 0x28, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x20, 0x3d, 0x3d, 0x20, 0x62, 0x6c, 0x6f, 
0x63, 0x6b, 0x5f, 0x73, 0x69, 0x7a, 0x65, 0x20, 0x2d, 0x20, 0x31, 0x29, 0x20, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x20, 0x75, 0x6e, 0x73, 0x69, 0x67, 0x6e, 0x65, 0x64, 0x20, 0x69, 0x6e, 0x74, 0x20, 0x74, 0x20, 0x3d, 0x20, 
0x74, 0x6d, 0x70, 0x5b, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5d, 0x20, 0x3d, 0x20, 0x30, 
0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 
0x69, 0x64, 0x5f, 0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 0x5f, 0x68, 0x61, 0x6c, 0x66, 0x5d, 0x20, 0x3d, 0x20, 0x74, 0x3b, 
0x0a, 0x20, 0x20, 0x20, 0x20, 0x7d, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x62, 0x61, 0x72, 0x72, 0x69, 0x65, 0x72, 0x28, 0x43, 
0x4c, 0x4b, 0x5f, 0x4c, 0x4f, 0x43, 0x41, 0x4c, 0x5f, 0x4d, 0x45, 0x4d, 0x5f, 0x46, 0x45, 0x4e, 0x43, 0x45, 0x29, 0x3b, 
0x0a, 0x20, 0x20, 0x20, 0x20, 0x69, 0x66, 0x20, 0x28, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x20, 0x3d, 0x3d, 
0x20, 0x30, 0x29, 0x20, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x70, 0x72, 0x69, 0x6e, 0x74, 0x66, 
0x28, 0x22, 0x68, 0x61, 0x6c, 0x66, 0x3a, 0x20, 0x25, 0x64, 0x5c, 0x6e, 0x22, 0x2c, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x64, 
0x6f, 0x75, 0x62, 0x6c, 0x65, 0x64, 0x5f, 0x62, 0x6c, 0x6f, 0x63, 0x6b, 0x5f, 0x73, 0x69, 0x7a, 0x65, 0x20, 0x2d, 0x20, 
0x31, 0x5d, 0x29, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x7d, 0x0a, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x66, 0x6f, 0x72, 0x28, 
0x75, 0x69, 0x6e, 0x74, 0x20, 0x73, 0x20, 0x3d, 0x20, 0x32, 0x3b, 0x20, 0x73, 0x20, 0x3c, 0x20, 0x64, 0x6f, 0x75, 0x62, 
0x6c, 0x65, 0x64, 0x5f, 0x62, 0x6c, 0x6f, 0x63, 0x6b, 0x5f, 0x73, 0x69, 0x7a, 0x65, 0x3b, 0x20, 0x73, 0x20, 0x3c, 0x3c, 
0x3d, 0x20, 0x31, 0x29, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x64, 
0x70, 0x20, 0x3e, 0x3e, 0x3d, 0x20, 0x31, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x62, 0x61, 0x72, 
0x72, 0x69, 0x65, 0x72, 0x28, 0x43, 0x4c, 0x4b, 0x5f, 0x4c, 0x4f, 0x43, 0x41, 0x4c, 0x5f, 0x4d, 0x45, 0x4d, 0x5f, 0x46, 
0x45, 0x4e, 0x43, 0x45, 0x29, 0x3b, 0x0a, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x69, 0x66, 0x28, 0x6c, 
0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x20, 0x3c, 0x20, 0x73, 0x29, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x75, 0x69, 0x6e, 0x74, 0x20, 
0x69, 0x20, 0x3d, 0x20, 0x64, 0x70, 0x2a, 0x28, 0x32, 0x20, 0x2a, 0x20, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 
0x20, 0x2b, 0x20, 0x31, 0x29, 0x20, 0x2d, 0x20, 0x31, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x20, 0x75, 0x69, 0x6e, 0x74, 0x20, 0x6a, 0x20, 0x3d, 0x20, 0x64, 0x70, 0x2a, 0x28, 0x32, 0x20, 0x2a, 0x20, 
0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x20, 0x2b, 0x20, 0x32, 0x29, 0x20, 0x2d, 0x20, 0x31, 0x3b, 0x0a, 0x0a, 
0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x75, 0x6e, 0x73, 0x69, 0x67, 0x6e, 0x65, 0x64, 
0x20, 0x69, 0x6e, 0x74, 0x20, 0x74, 0x20, 0x3d, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x6a, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x6a, 0x5d, 0x20, 0x2b, 0x3d, 0x20, 0x74, 
0x6d, 0x70, 0x5b, 0x69, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x74, 
0x6d, 0x70, 0x5b, 0x69, 0x5d, 0x20, 0x3d, 0x20, 0x74, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x7d, 
0x0a, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x69, 0x66, 0x28, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 
0x64, 0x5f, 0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 0x5f, 0x68, 0x61, 0x6c, 0x66, 0x20, 0x3c, 0x20, 0x73, 0x29, 0x0a, 0x20, 
0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x75, 0x69, 0x6e, 0x74, 0x20, 0x69, 0x20, 0x3d, 0x20, 0x64, 0x70, 0x2a, 0x28, 0x32, 0x20, 0x2a, 0x20, 0x6c, 0x6f, 
0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5f, 0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 0x5f, 0x68, 0x61, 0x6c, 0x66, 0x20, 0x2b, 
0x20, 0x31, 0x29, 0x20, 0x2d, 0x20, 0x31, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x75, 0x69, 0x6e, 0x74, 0x20, 0x6a, 0x20, 0x3d, 0x20, 0x64, 0x70, 0x2a, 0x28, 0x32, 0x20, 0x2a, 0x20, 0x6c, 0x6f, 
0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5f, 0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 0x5f, 0x68, 0x61, 0x6c, 0x66, 0x20, 0x2b, 
0x20, 0x32, 0x29, 0x20, 0x2d, 0x20, 0x31, 0x3b, 0x0a, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x75, 0x6e, 0x73, 0x69, 0x67, 0x6e, 0x65, 0x64, 0x20, 0x69, 0x6e, 0x74, 0x20, 0x74, 0x20, 0x3d, 0x20, 0x74, 
0x6d, 0x70, 0x5b, 0x6a, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x74, 
0x6d, 0x70, 0x5b, 0x6a, 0x5d, 0x20, 0x2b, 0x3d, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x69, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x69, 0x5d, 0x20, 0x3d, 0x20, 0x74, 0x3b, 
0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x7d, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x7d, 0x0a, 0x0a, 0x20, 0x20, 
0x20, 0x20, 0x62, 0x61, 0x72, 0x72, 0x69, 0x65, 0x72, 0x28, 0x43, 0x4c, 0x4b, 0x5f, 0x4c, 0x4f, 0x43, 0x41, 0x4c, 0x5f, 
0x4d, 0x45, 0x4d, 0x5f, 0x46, 0x45, 0x4e, 0x43, 0x45, 0x29, 0x3b, 0x0a, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x69, 0x66, 0x20, 
0x28, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x20, 0x3c, 0x20, 0x6e, 0x29, 0x20, 0x7b, 0x0a, 0x20, 0x20, 0x20, 
0x20, 0x20, 0x20, 0x20, 0x20, 0x70, 0x72, 0x65, 0x66, 0x5f, 0x73, 0x75, 0x6d, 0x5b, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 
0x69, 0x64, 0x5d, 0x20, 0x3d, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5d, 0x3b, 
0x0a, 0x20, 0x20, 0x20, 0x20, 0x7d, 0x0a, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x69, 0x66, 0x20, 0x28, 0x6c, 0x6f, 0x63, 0x61, 
0x6c, 0x5f, 0x69, 0x64, 0x5f, 0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 0x5f, 0x68, 0x61, 0x6c, 0x66, 0x20, 0x3c, 0x20, 0x6e, 
0x29, 0x20, 0x7b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x70, 0x72, 0x65, 0x66, 0x5f, 0x73, 0x75, 0x6d, 
0x5b, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5f, 0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 0x5f, 0x68, 0x61, 0x6c, 
0x66, 0x5d, 0x20, 0x3d, 0x20, 0x74, 0x6d, 0x70, 0x5b, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x5f, 0x69, 0x64, 0x5f, 0x73, 0x65, 
0x63, 0x6f, 0x6e, 0x64, 0x5f, 0x68, 0x61, 0x6c, 0x66, 0x5d, 0x3b, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x7d, 0x0a, 0x7d, 0x0a, 
};

static size_t for_test___half_sized_scan_kernel_length = sizeof(for_test___half_sized_scan_kernel) / sizeof(char);

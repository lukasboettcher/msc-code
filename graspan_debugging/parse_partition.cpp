
#include <iostream>

using namespace std;

int main(int argc, char const *argv[])
{
	int k = 0;
	long sz;
	string str = "Partition" + to_string(k);
	// FILE *fp = fopen(str.c_str(), "rb");
	FILE *fp = fopen(argv[1], "rb");
	fseek(fp, 0L, SEEK_END);
	sz = ftell(fp);
	rewind(fp);

	// uint poolSize = p.oldSize + p.deltaSize + p.tmpSize;
	uint *elements = new uint[sz];
	fread(elements, sizeof(uint), sz, fp);
	fclose(fp);

	for (size_t i = 0; i < sz; i++)
	{
		cout << elements[i] << endl;
	}

	return 0;
}

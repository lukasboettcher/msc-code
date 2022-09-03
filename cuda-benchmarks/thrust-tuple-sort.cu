#include <thrust/sort.h>
#include <thrust/device_vector.h>

int main(int argc, char const *argv[])
{
    const int N = 6;
    thrust::device_vector<int> keys(N);
    keys[0] = 7;
    keys[1] = 12;
    keys[2] = 13;
    keys[3] = 12;
    keys[4] = 13;
    keys[5] = 7;

    thrust::device_vector<int> vals(N);
    vals[0] = 4;
    vals[1] = 13;
    vals[2] = 5;
    vals[3] = 1;
    vals[4] = 4;
    vals[5] = 2;

    auto kv_start = thrust::make_zip_iterator(thrust::make_tuple(keys.begin(), vals.begin()));

    thrust::sort(thrust::device, kv_start, kv_start + N);

    std::cout << "keys after sort: [ ";
    thrust::copy(keys.begin(), keys.end(), std::ostream_iterator<int>(std::cout, " "));
    std::cout << "]" << std::endl;
    std::cout << "vals after sort: [ ";
    thrust::copy(vals.begin(), vals.end(), std::ostream_iterator<int>(std::cout, " "));
    std::cout << "]" << std::endl;
    return 0;
}

#ifndef LANCZOS_DEVICE_CONTAINER_H
#define LANCZOS_DEVICE_CONTAINER_H
#include<vector>
namespace lanczos{
  namespace detail{
    template<class Container>
    auto getRawPointer(Container &vec){
      return vec.data();
    }
  }
}
#ifdef CUDA_ENABLED
#include<thrust/device_vector.h>
namespace lanczos{
  template<class T> using device_container = thrust::device_vector<T>;
  namespace detail{
    template<class T>
    auto getRawPointer(thrust::device_vector<T> &vec){
      return thrust::raw_pointer_cast(vec.data());
    }

    template<class Iter, class Iter2>
    void device_copy(Iter begin, Iter end, Iter2 out){
      thrust::copy(begin, end, out);
    }
    template<class Iter, class T>
    void device_fill(Iter begin, Iter end, T value){
      thrust::fill(begin, end, value);
    }

  }  
}
#else
namespace lanczos{
  template<class T> using device_container = std::vector<T>;
  namespace detail{
    template<class Iter, class Iter2>
    void device_copy(Iter begin, Iter end, Iter2 out){
      std::copy(begin, end, out);
    }
    template<class Iter, class T>
    void device_fill(Iter begin, Iter end, T value){
      std::fill(begin, end, value);
    }


  }
}
#endif

#endif

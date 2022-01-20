/*Raul P. Pelaez 2022. Lanczos solver CPU/GPU example
This code will compute and print sqrt(M)*v using the iterative Krylov solver in [1].

In this usage example, the matrix M is a diagonal matrix and v is filled with ones.

The code below uses a series of utilities available in the library to make it work in either the CPU or GPU.

If this code is compiled with CUDA_ENABLED defined, the code will run in a GPU. Otherwise it will be CPU only.

References:
  [1] Krylov subspace methods for computing hydrodynamic interactions in Brownian dynamics simulations
  J. Chem. Phys. 137, 064106 (2012); doi: 10.1063/1.4742347
 */
#include<iostream>
#include <LanczosAlgorithm.h>

//Using this floating point type (either float or double) will make the code be compiled with the same
// precision as the library.
using real = lanczos::real;

//A functor that will return the result of multiplying a certain matrix times a given vector
struct MatrixDot{
  int size;
  MatrixDot(int size): size(size){}
  
  void operator()(real* v, real* Mv){
    //An example diagonal matrix
    for(int i=0; i<size; i++){
      Mv[i] = (2+i/10.0)*v[i];
    }
  }

};


int main(){
  {
    //Initialize the solver
    real tolerance = 1e-6;
    lanczos::Solver lanczos(tolerance);
    int size = 10;
    //A vector filled with 1.
    //Lanczos defines this type for convenience. It will be a thrust::device_vector if CUDA_ENABLED is defined and an std::vector otherwise
    lanczos::device_container<real> v(size);
    lanczos::detail::device_fill(v.begin(), v.end(), 1);
    //A vector to store the result of sqrt(M)*v
    lanczos::device_container<real> result(size);
    //A functor that multiplies by ta diagonal matrix
    MatrixDot dot(size);
    //Call the solver
    real* d_result = lanczos::detail::getRawPointer(result);
    real* d_v = lanczos::detail::getRawPointer(v);
    int numberIterations = lanczos.solve(dot, d_result, d_v, size);
    std::cout<<"Solved after "<<numberIterations<< " iterations"<<std::endl;
    //Now result is filled with sqrt(M)*v = sqrt(2)*[1,1,1...1]
    std::cout<<"Result: ";for(int i = 0; i<10; i++) std::cout<<result[i]<<" "; std::cout<<std::endl;
    //Compute error
    std::cout<<"Error: ";
    for(int i = 0; i<10; i++){
      real truth = sqrt(2+i/10.0);
      std::cout<<abs(result[i]-truth)/truth<<" ";
    }
    std::cout<<std::endl;
    
  }
  return 0;
}
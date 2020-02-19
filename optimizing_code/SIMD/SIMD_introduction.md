## SIMD Concept

One instruction performs the same instruction on multiple data elements. 

The most simple SIMD instructions operate of 128-bit length registers (AVX instructions). A register is simply a place where processors can store bits and acces them at super speeds. The 128 bits from a register can represnet different things.

- 16 bytes

- 8 halfwords

- 4 words:  A word is a fixed-sized [piece of data](https://en.wikipedia.org/wiki/Data_(computing)) handled as a unit by the [instruction set](https://en.wikipedia.org/wiki/Instruction_set) or the hardware of the processor.

- 2 doublewords

Examples of words and double words

- 4 SP FPs (Single Precision Floating Points):       4 numbers of type Float32 

- 2 DP Fps: (Double Precision Floating Points):    2  numbers of type Float64



#### Packed/Parallel Addition and Substraction

PADD operation:

```
[A1, A2, A3, A4] + [B1, B2, B3, B4] = [A1+B1, A2+B2, A3+B3, A4+B4]
```

PSUB operation:

```
[A1, A2, A3, A4] - [B1, B2, B3, B4] = [A1-B1, A2-B2, A3-B3, A4-B4]
```

Almost all SIMD extensions support intrinsic (operations) with clipping.

Clipping (also sometimes referred to as saturation) is the operation of keeping the minimum value of a data type if an operation underflows or keeping the maximum value of a datatype if the operation underflows. 

For example let us conside the case where we are operating with pixel intensities. Each pixel is a tuple containing 3 numbers that represent the quantity of Red Blue and Green in the pixel (hence the name RGB). 

Let us assume we work with  Int8 pixel intensities. Therefore, the maximum value that is representable is $2^8-1 = 255$.

If we do a normal sum using standard  Int8 values and we do (234,235,236) plus (22,23,24) we get...

Standard wrap-around sum
$$
(234,235,236) + (22,23,24) = (0,2,4)
$$
which might not be what we wanted. Notice that (255,255,255) is white and (0,0,0) is black. Therefore adding something very close to pure wite with a bit of vlack we get asomething that is completly black (because of the overflow).

Sum with clipping
$$
Clip \left( (234,235,236), (22,23,24) \right) = (254,255,255)
$$
To do this we have `ss` and `us` versions of the SIMD instructions

- PADD{b,h,w,d}           wrap-around (modulo) arithmetic
- PADD{b,h,w,d}, ss     signed saturation
- PADD{b,h,w,d}, us     unsigned saturation



### Multiplications with SIMD

https://www.youtube.com/watch?v=OfipsVWFxgM&list=PLeWkeA7esB-PcOTrTCvAsaCArnCMQkcNv&index=19

Multiplying 2 n-bit numbers produces a 2n-bit number. How do we deal with this? 

Notice that, assuming we use a datatype that can store n bits, the result of dealing with 2 n-bit numbers is a 2n-bit number. Therefore, it cannot be stored in the same datatype!

- Even/odd
- Multiply hi/lo
- Reduction
- Higher precision result register





## XMM Register

Imagine a function that recieves 3 Float32 (a,b,c) values and updates c with a+b

In julia this would be

```
function sum!(c,a,b)
    c = a + b
end
```

If we assume a::Float32, b::Float32, c::Float32 this function can be computed using registers with the following memory layout:

```
XMM0 = [0, 0, 0, a]
XMM1 = [0, 0, 0, b]
XMM2 = [0, 0, 0, c]
```

Notice that this representation assumes each 0 is a Float32 and a,b,c are also Float32 values.

If we assume a::Float64, b::Float64, c::Float64 this function can be computed using registers with the following memory layout:

```
XMM0 = [0, a]
XMM1 = [0, b]
XMM2 = [0, c]
```

Now, since each value need double the amount of bits (and the registers have a fix size length of 128 bits)
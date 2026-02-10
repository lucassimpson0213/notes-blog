+++
title = "Bits Explanation"
date = "2026-02-08"
updated = "2022-05-01"
[taxonomies]
tags=["osdev"]

[extra]

comment = true
+++


# Manipulating Bits in the Context of Operating Systems
The following are various bit tricks and bit manipulation techniques.
This is a sounding board for my bit practice.

## Setting bits in a given number
Say we would like to set the bit of a specific number. For Simplicity's sake
we will use an 8 bit integer.

Let's define a sample 8 bit integer


```go
func main() {
    var x uint8 = 0b01010110
}
```
We want to set the bit for a specific number. This is typically done through
something called a mask.

A mask is a way to define the bits you want to keep or the bits you want to clear.

If you wanted to mask the 4th bit, the 3rd bit zero indexed, you would do the following
```go
func main() {
    var x uint8 = 0b01010110
    var mask uint8 = 0b00001000
    // use logical or to set bit
    var maskedx uint8 = x | mask
    //result: 0b01011110

}

```

## Setting a range of bits

If you would like to set a range of bits
there's a few steps that you have to take:
1. clear the bits
2. create a mask
3. shift that mask to the position of the cleared bits
```go

func main() {
    var x uint8 = 0b01100110

}
```
### create the mask
The range that we want to set is the 4th bit from the left to the
7th:

<p align="center" >0b0 <strong>101</strong>  0000</p>




```go

func main() {
    var x uint8 = 0b01100110
    //decimal number 102

    var mask uint8 = 0b01010000
    //
}
```

## clear the bits

A really clean way to clear the exact bits that you want is to
take the mask we have already and flip it.

so you take your current mask and flip it --- 0b10101111

```go

func main() {
    var x uint8 = 0b01100110
    //decimal number 102

    var mask uint8 = 0b01010000
    // we want the mask to be 10101111
    x &= ~mask

    //x is now

}
```


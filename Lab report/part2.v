module full_add( sum , carry , in1 , in2 , in3 );
input in1 , in2 , in3;
output sum , carry;
wire w1 , w2 , w3;
xor( w1 , in1 , in2 );
xor( sum , w1 , in3 );
and( w2 , in1 , in2 );
and( w3 , w1 , in3 );
or( carry , w2 , w3 );
endmodule

module add_sub( sum1 , count , inp1 , inp2 , M );
input [ 3 : 0 ] inp1 , inp2;
input M;
output [ 3 : 0 ] sum1;
output count ;
wire w4 , w5 , w6 , w7;
xor( w8 , M , inp2[0] );
xor( w9 , M , inp2[1] );
xor( w10 , M , inp2[2] );
xor( w11 , M , inp2[3] );
full_add f1( sum1[0] , w4 , inp1[0] , w8 , M );
full_add f2( sum1[1] , w5 , inp1[1] , w9 , w4 );
full_add f3( sum1[2] , w6 , inp1[2] , w10 , w5 );
full_add f4( sum1[3] , count , inp1[3] , w11 , w6 );
endmodule

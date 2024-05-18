`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2024 01:12:38 AM
// Design Name: 
// Module Name: SRAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module SRAM(
    input clk , 
    input cen , 
    input wen , 
    input oen , 
    input [16:0] addr , 
    inout [7:0] data
);
reg [7:0] D ; 
reg [7:0] RAM [2**17-1:0] ; 
always@(*) begin
    if(!cen) begin 
     D <=  RAM[addr] ;
    end
end
always@(negedge clk) begin
    if(!cen) begin 
		  if (!wen) //write
			RAM[addr] <= data ; 
    end 
end
assign data = (!oen && wen) ? D : 8'bz ;  
endmodule 

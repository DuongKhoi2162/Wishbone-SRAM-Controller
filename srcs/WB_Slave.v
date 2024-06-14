`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2024 02:36:06 PM
// Design Name: 
// Module Name: WB_Slave
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


module WB_Slave(
    input CLK_I , 
    input RST_I , 
    output [31:0] DAT_I , 
    output reg ACK_I , 
    input [31:0] ADR_O , 
    input [31:0] DAT_O , 
    input WE_O ,
    input STB_O , 
    input CYC_O , 
    output reg [31:0] s_addr ,
    input [31:0] s_rdata , 
    output reg [31:0] s_wdata , 
    output reg s_we , 
    input sram_wr_finish , 
    output reg s_access
    
    );
reg [1:0] state = IDLE ; 
parameter IDLE = 2'b00 , SEND_ACK = 2'b01 , ACK = 2'b11 ; 
always@(posedge CLK_I or posedge RST_I ) begin 
    if(RST_I) begin 
        state <= IDLE ; 
        ACK_I <= 0 ; 
        s_access <= 0 ; 
    end 
    else begin 
        case(state)
            IDLE: begin 
                s_addr <= ADR_O ;
                s_access <= 0 ;  
                ACK_I <= 0 ; 
                if(STB_O && CYC_O) begin
                    state <= SEND_ACK ; 
                    s_we <= WE_O ; 
                    s_access <= 1 ; 
                end 
            end
            SEND_ACK: begin 
                s_addr <= ADR_O ;
                s_access <= 0 ; 
                if(WE_O) s_wdata <= DAT_O ;
                if(STB_O && CYC_O) begin
                    ACK_I <= 1; 
                    state <= ACK ;
                    s_access <= 1 ; 
                    s_we <= WE_O ; 
                end 
            end 
            ACK: begin
                    s_addr <= ADR_O ;
                    if(WE_O)s_wdata <= DAT_O  ;
                    if (sram_wr_finish) begin
                        state <= IDLE;
                        s_access <= 0 ; 
                        ACK_I <= 0 ; 
                    end
                    else state <= ACK; 
                end
        endcase
    end 
end  
assign DAT_I  = (!WE_O && state == ACK ) ? s_rdata : 32'bz ;
endmodule
                

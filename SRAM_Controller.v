`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2024 02:20:30 PM
// Design Name: 
// Module Name: SRAM_Controller
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


module SRAM_Controller(
    input clk ,
    input rst , 
    input [31:0] s_addr , 
    output reg [31:0] s_rdata,
    input [31:0] s_wdata,
    input s_we ,
    output reg sram_wr_finish, 
    input s_access , 
    output reg [16:0] Sram_addr, 
    inout  [7:0] Sram_iodata,
    output reg Sram_wen,
    output reg Sram_oen,
    output reg Sram_cen);
wire [7:0] W_Data [0:3] ; 
reg [7:0] R_Data [0:3] ; 
    //FSM 
reg [2:0] state = IDLE  ;
reg [2:0] next_state ; 
reg [7:0] data_sram ;  
integer count = 0 ; 
parameter IDLE = 3'b000, READ = 3'b001 , READ_FINISH = 3'b010 , WRITE = 3'b011 , WRITE_FINISH = 3'b100 ; 
always@(*) begin 
        case(state)
            IDLE:   begin
               count <= 0 ; 
               if(s_access) begin 
                    if(s_we)
                        next_state <= WRITE ; 
                    else 
                        next_state <= READ ;
                end
               else next_state <= IDLE ; 
            end
            READ:   begin
                if(s_access) begin 
                    if(count==2) next_state <= READ_FINISH ; 
                    else begin 
                    next_state <= READ ; 
                    end 
                end 
            end 
            READ_FINISH:    begin 
                count <= 0 ; 
                next_state <= IDLE ; 
            end
            WRITE:  begin
               if(s_access) begin 
                    if(count==2) next_state <= WRITE_FINISH ; 
                    else begin  
                        next_state <= WRITE ;     
                        end
                    end 
            end 
            WRITE_FINISH:   begin
                count <= 0 ;
                next_state <= IDLE ;                 
            end         
    endcase
end 
always@(posedge clk or negedge rst) begin 
    if(!rst) begin 
        count <= 0 ; 
        state <= IDLE ; 
    end 
    else begin 
        state <= next_state ; 
        if (s_access) begin 
        if(state == READ || state == WRITE) count <= count + 1 ; 
        else count <= 0 ; 
        end
    end
end 
always@(*)begin
     case(state)
        READ: begin
           case(count)
                0: s_rdata[7:0] <= Sram_iodata ; 
                1: s_rdata[15:8] <= Sram_iodata ; 
                2: s_rdata[23:16] <= Sram_iodata ; 
           endcase
        end
        READ_FINISH:
           if(clk) begin 
                s_rdata[31:24] <= Sram_iodata ;
           end 
     endcase
end 
always@(*) begin 
    case(state)
            IDLE:   begin
                Sram_addr <= 17'bx ;
                Sram_wen <= 1 ; 
                Sram_oen <= 1 ; 
                Sram_cen <= 1 ; 
                sram_wr_finish <= 0 ;   
            end
            READ:   begin
                Sram_addr <= s_addr + count ; 
                Sram_wen <= 1 ; 
                Sram_oen <= 0 ; 
                Sram_cen <= 0 ;
                sram_wr_finish <= 0 ;     
            end 
            READ_FINISH:    begin 
                Sram_addr <= s_addr + 3 ;
                Sram_wen <= 1 ; 
                Sram_oen <= 0 ; 
                Sram_cen <= 0 ;   
                sram_wr_finish <= 1 ;  
            end
            WRITE:  begin
                data_sram <= W_Data[count]; 
                Sram_addr <= s_addr + count ; 
                Sram_wen <= 0 ; 
                Sram_oen <= 1 ; 
                Sram_cen <= 0 ;   
                sram_wr_finish <= 0;  
            end 
            WRITE_FINISH:   begin
                data_sram <= W_Data[3]; 
                Sram_addr <= s_addr + 3 ;
                Sram_wen <= 0 ; 
                Sram_oen <= 1 ; 
                Sram_cen <= 0 ;  
                sram_wr_finish <= 1; 
            end         
    endcase
end 
assign W_Data[0] = s_wdata[7:0] ; 
assign W_Data[1] = s_wdata[15:8];
assign W_Data[2] = s_wdata[23:16];
assign W_Data[3] = s_wdata[31:24];
assign Sram_iodata = (state==WRITE||state ==WRITE_FINISH)? data_sram : 8'bz   ; 
endmodule

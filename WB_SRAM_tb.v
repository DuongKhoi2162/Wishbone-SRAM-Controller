`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2024 11:21:38 PM
// Design Name: 
// Module Name: WB_SRAM_tb
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

module WB_SRAM_tb();
    reg CLK_I ; 
    reg RST_I ; 
    wire [31:0] DAT_I ; 
    wire ACK_I ; 
    reg [31:0] ADR_O ; 
    reg [31:0] DAT_O ; 
    reg WE_O ;
    reg  STB_O ; 
    reg CYC_O ; 
    wire [31:0] s_addr ;
    wire [31:0] s_rdata ; 
    wire [31:0] s_wdata ; 
    wire s_we ; 
    wire sram_wr_finish ; 
    wire s_access;
    wire [16:0]Sram_addr;
    wire [7:0] Sram_iodata;
    wire Sram_wen;
    wire Sram_oen;
    wire Sram_cen; 
parameter simulation_cycle = 100 ; 
WB_Slave DUT(.CLK_I(CLK_I) , 
    .RST_I(RST_I) , 
    .DAT_I(DAT_I) , 
    .ACK_I(ACK_I) , 
    .ADR_O(ADR_O) , 
    .DAT_O(DAT_O) , 
    .WE_O(WE_O) ,
    .STB_O(STB_O) , 
    .CYC_O(CYC_O) , 
    .s_addr(s_addr) ,
    .s_rdata(s_rdata) , 
    .s_wdata(s_wdata) , 
    .s_we(s_we) , 
    .sram_wr_finish(sram_wr_finish) , 
    .s_access(s_access));
SRAM_Controller dut (.clk(CLK_I),
                    .rst(!RST_I),
                    .s_addr(s_addr),
                    .s_rdata(s_rdata),
                    .s_wdata(s_wdata),
                    .s_we(s_we),
                    .sram_wr_finish(sram_wr_finish),
                    .s_access(s_access),
                    .Sram_addr(Sram_addr),
                    .Sram_iodata(Sram_iodata),
                    .Sram_wen(Sram_wen),
                    .Sram_oen(Sram_oen),
                    .Sram_cen(Sram_cen));
SRAM sram(.clk(CLK_I),
          .cen(Sram_cen),
          .wen(Sram_wen),
          .oen(Sram_oen),
          .addr(Sram_addr),
          .data(Sram_iodata));
always #(simulation_cycle/2) CLK_I = !CLK_I ; 
initial begin
//write abcdef12 to address ADR_O[16:0] 
    CLK_I <= 0 ; 
    RST_I <= 0 ; 
    ADR_O <= 32'hABCDABCD; 
    WE_O <= 1 ; 
    DAT_O <= 32'habcdef12; 
    STB_O <= 0 ;
    CYC_O <= 0 ;
    #((simulation_cycle/2)-1) ; 
    STB_O <= 1 ;
    CYC_O <= 1 ; 
    repeat(5) #simulation_cycle ; 
    DP_Write();
    STB_O <= 0 ; 
    repeat(1) #simulation_cycle ; 
    STB_O <= 1 ; 
//write 12345678 to address ADR_O[16:0] 
    WE_O <= 1 ; 
    ADR_O <= 32'h00000752; 
    DAT_O <= 32'h12345678;
    repeat(5) #simulation_cycle ; 
    DP_Write();
    STB_O <= 0 ; 
    repeat(1) #simulation_cycle ; 
    //read at ADR_O[16:0]
    STB_O <= 1 ;  
    WE_O <= 0 ;
    ADR_O <= 32'hABCDABCD;
    repeat(5) #simulation_cycle ; 
    DP_Read();
    STB_O <= 0 ;   
    repeat(1) #simulation_cycle ; 
    STB_O <= 1 ;
    //read at ADR_O[16:0]
    ADR_O <= 32'h00000752;  
    repeat(5) #simulation_cycle ; 
    DP_Read();
    STB_O <= 0 ;
    CYC_O <= 0 ;   
    repeat(1) #simulation_cycle ; 
    STB_O <= 1 ;
    CYC_O <= 1 ; 
    WE_O <= 1 ;
    ADR_O <= 32'hABCDFFF0;
    DAT_O <= 32'h01020304;
    repeat(3) #simulation_cycle ; 
    //reset
    RST_I <= 1 ; 
    repeat(1) #simulation_cycle ; 
    RST_I <= 0 ; 
    DAT_O <= 32'hABCD2024;
    repeat(5) #simulation_cycle ;
    DP_Write(); 
    STB_O <= 0 ;   
    CYC_O <= 0 ; 
    #simulation_cycle ;
    $stop;
end 
task DP_Write();
    if({sram.RAM[ADR_O[16:0]+3],sram.RAM[ADR_O[16:0]+2],sram.RAM[ADR_O[16:0]+1],sram.RAM[ADR_O[16:0]]} == DAT_O) begin 
        $display("Successfully write %h to address %h",DAT_O,ADR_O[16:0]);
    end
    else $display("Error, Expected value:%h, Actual value:%h ",DAT_O,{sram.RAM[ADR_O[16:0]+3],sram.RAM[ADR_O[16:0]+2],sram.RAM[ADR_O[16:0]+1],sram.RAM[ADR_O[16:0]]});
endtask: DP_Write
task DP_Read();
    if(DAT_I == {sram.RAM[ADR_O[16:0]+3],sram.RAM[ADR_O[16:0]+2],sram.RAM[ADR_O[16:0]+1],sram.RAM[ADR_O[16:0]]}) begin 
        $display("Successfully read from address %h, value:%h",ADR_O[16:0],DAT_I);
    end
    else $display("Error, Expected value:%h, Actual value:%h ",DAT_I,{sram.RAM[ADR_O[16:0]+3],sram.RAM[ADR_O[16:0]+2],sram.RAM[ADR_O[16:0]+1],sram.RAM[ADR_O[16:0]]});
endtask: DP_Read
endmodule 

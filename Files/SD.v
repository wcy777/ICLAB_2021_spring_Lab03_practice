//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2021 ICLAB Spring Course practice
//   Lab02     : Sudoku (SD)
//   Author    : Chun-Yi Wang (eric88728@gmail.com)
//   Date      : 2022-09-26 ~ 2022-09-29
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SD.v
//   Module Name : SD
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`define del 1
module SD (
    // Input signals
    clk,
    rst_n,
	in_valid,
	in,
    // Output signals
    out_valid,
    out
);

//-----------------------------------------------------------------------------------------//
/*input / output declaration*/
input clk, rst_n;
input in_valid;
input [3:0] in;

output reg out_valid;
output reg [3:0] out;

//-----------------------------------------------------------------------------------------//
/*wire / register / parameter / integer / genvar declaration*/

integer i;
//
localparam IDLE = 2'b00, READ = 2'b01, CALCULATE = 2'b10, OUT = 2'b11;
//
reg [2:0] current_state, next_state; //state

reg [3:0] in_reg [0:80];                   //input register
reg [6:0] in_index;                        //input register index
   
reg [3:0] blank_address_row    [0:14];     //compare use row address
reg [6:0] blank_address_column [0:14];     //compare use column address
reg [5:0] blank_address_grid   [0:14];     //compare use grid address
reg [3:0] blank_address_row_tmp    [0:14];     //blank's row address
reg [6:0] blank_address_column_tmp [0:14];     //blank's column address
reg [5:0] blank_address_grid_tmp   [0:14];     //blank's gridressd ad
reg [3:0] ba_index;                        //blank address index  

reg [6:0] blank_position [0:14];           //blank position index in input register
reg [3:0] bp_index;                 


reg [3:0] row_cnt;
reg [6:0] column_cnt;
reg [5:0] grid_cnt;

reg [3:0] flag_index;                   //blank address index while compute
wire [3:0] flag_index_backward;         //flag_index while step back to last position

reg [3:0] out_reg_index;    //output register index

reg wrong_input_en;         //equal to 1'b1 because the sudoku with blank is already wrong during READ
//
wire row_flag;               //determine row available
wire column_flag;            //determine column available
wire grid_flag;              //determine grid available

wire cmp_en;                 //available value of the blank(row_flag, column_flag, grid_flag all 1)

wire fail_en;                      //if the blank doesn't have any available value : 1'b1

//-----------------------------------------------------------------------------------------//
/*CALAULATION*/

//-- row_flag       //compare all row position does not have same value except 0
assign row_flag = ((in_reg[blank_address_row[flag_index]] == in_reg[blank_address_row[flag_index]+9] && in_reg[blank_address_row[flag_index]] != 4'b0)  || (in_reg[blank_address_row[flag_index]] == in_reg[blank_address_row[flag_index]+18] && in_reg[blank_address_row[flag_index]] != 4'b0)  ||
                   (in_reg[blank_address_row[flag_index]] == in_reg[blank_address_row[flag_index]+27] && in_reg[blank_address_row[flag_index]] != 4'b0) || (in_reg[blank_address_row[flag_index]] == in_reg[blank_address_row[flag_index]+36] && in_reg[blank_address_row[flag_index]] != 4'b0)  ||
                   (in_reg[blank_address_row[flag_index]] == in_reg[blank_address_row[flag_index]+45] && in_reg[blank_address_row[flag_index]] != 4'b0) || (in_reg[blank_address_row[flag_index]] == in_reg[blank_address_row[flag_index]+54] && in_reg[blank_address_row[flag_index]] != 4'b0)  ||
                   (in_reg[blank_address_row[flag_index]] == in_reg[blank_address_row[flag_index]+63] && in_reg[blank_address_row[flag_index]] != 4'b0) || (in_reg[blank_address_row[flag_index]] == in_reg[blank_address_row[flag_index]+72] && in_reg[blank_address_row[flag_index]] != 4'b0)  ||
                   
                   (in_reg[blank_address_row[flag_index]+9] == in_reg[blank_address_row[flag_index]+18] && in_reg[blank_address_row[flag_index]+9] != 4'b0) || (in_reg[blank_address_row[flag_index]+9] == in_reg[blank_address_row[flag_index]+27] && in_reg[blank_address_row[flag_index]+9] != 4'b0) ||
                   (in_reg[blank_address_row[flag_index]+9] == in_reg[blank_address_row[flag_index]+36] && in_reg[blank_address_row[flag_index]+9] != 4'b0) || (in_reg[blank_address_row[flag_index]+9] == in_reg[blank_address_row[flag_index]+45] && in_reg[blank_address_row[flag_index]+9] != 4'b0) ||
                   (in_reg[blank_address_row[flag_index]+9] == in_reg[blank_address_row[flag_index]+54] && in_reg[blank_address_row[flag_index]+9] != 4'b0) || (in_reg[blank_address_row[flag_index]+9] == in_reg[blank_address_row[flag_index]+63] && in_reg[blank_address_row[flag_index]+9] != 4'b0) ||
                   (in_reg[blank_address_row[flag_index]+9] == in_reg[blank_address_row[flag_index]+72] && in_reg[blank_address_row[flag_index]+9] != 4'b0) || 

                   (in_reg[blank_address_row[flag_index]+18] == in_reg[blank_address_row[flag_index]+27] && in_reg[blank_address_row[flag_index]+18] != 4'b0) || (in_reg[blank_address_row[flag_index]+18] == in_reg[blank_address_row[flag_index]+36] && in_reg[blank_address_row[flag_index]+18] != 4'b0) ||
                   (in_reg[blank_address_row[flag_index]+18] == in_reg[blank_address_row[flag_index]+45] && in_reg[blank_address_row[flag_index]+18] != 4'b0) || (in_reg[blank_address_row[flag_index]+18] == in_reg[blank_address_row[flag_index]+54] && in_reg[blank_address_row[flag_index]+18] != 4'b0) ||
                   (in_reg[blank_address_row[flag_index]+18] == in_reg[blank_address_row[flag_index]+63] && in_reg[blank_address_row[flag_index]+18] != 4'b0) || (in_reg[blank_address_row[flag_index]+18] == in_reg[blank_address_row[flag_index]+72] && in_reg[blank_address_row[flag_index]+18] != 4'b0) ||

                   (in_reg[blank_address_row[flag_index]+27] == in_reg[blank_address_row[flag_index]+36] && in_reg[blank_address_row[flag_index]+27] != 4'b0) || (in_reg[blank_address_row[flag_index]+27] == in_reg[blank_address_row[flag_index]+45] && in_reg[blank_address_row[flag_index]+27] != 4'b0) ||
                   (in_reg[blank_address_row[flag_index]+27] == in_reg[blank_address_row[flag_index]+54] && in_reg[blank_address_row[flag_index]+27] != 4'b0) || (in_reg[blank_address_row[flag_index]+27] == in_reg[blank_address_row[flag_index]+63] && in_reg[blank_address_row[flag_index]+27] != 4'b0) ||
                   (in_reg[blank_address_row[flag_index]+27] == in_reg[blank_address_row[flag_index]+72] && in_reg[blank_address_row[flag_index]+27] != 4'b0) ||

                   (in_reg[blank_address_row[flag_index]+36] == in_reg[blank_address_row[flag_index]+45] && in_reg[blank_address_row[flag_index]+36] != 4'b0) || (in_reg[blank_address_row[flag_index]+36] == in_reg[blank_address_row[flag_index]+54] && in_reg[blank_address_row[flag_index]+36] != 4'b0) ||
                   (in_reg[blank_address_row[flag_index]+36] == in_reg[blank_address_row[flag_index]+63] && in_reg[blank_address_row[flag_index]+36] != 4'b0) || (in_reg[blank_address_row[flag_index]+36] == in_reg[blank_address_row[flag_index]+72] && in_reg[blank_address_row[flag_index]+36] != 4'b0) ||
                   
                   (in_reg[blank_address_row[flag_index]+45] == in_reg[blank_address_row[flag_index]+54] && in_reg[blank_address_row[flag_index]+45] != 4'b0) || (in_reg[blank_address_row[flag_index]+45] == in_reg[blank_address_row[flag_index]+63] && in_reg[blank_address_row[flag_index]+45] != 4'b0) ||
                   (in_reg[blank_address_row[flag_index]+45] == in_reg[blank_address_row[flag_index]+72] && in_reg[blank_address_row[flag_index]+45] != 4'b0) ||

                   (in_reg[blank_address_row[flag_index]+54] == in_reg[blank_address_row[flag_index]+63] && in_reg[blank_address_row[flag_index]+54] != 4'b0) || (in_reg[blank_address_row[flag_index]+54] == in_reg[blank_address_row[flag_index]+72] && in_reg[blank_address_row[flag_index]+54] != 4'b0) ||

                   (in_reg[blank_address_row[flag_index]+63] == in_reg[blank_address_row[flag_index]+72] && in_reg[blank_address_row[flag_index]+63] != 4'b0))? 1'b0: 1'b1;

//-- column_flag
assign column_flag = ((in_reg[blank_address_column[flag_index]] == in_reg[blank_address_column[flag_index]+1] && in_reg[blank_address_column[flag_index]] != 4'b0) || (in_reg[blank_address_column[flag_index]] == in_reg[blank_address_column[flag_index]+2] && in_reg[blank_address_column[flag_index]] != 4'b0)  ||
                      (in_reg[blank_address_column[flag_index]] == in_reg[blank_address_column[flag_index]+3] && in_reg[blank_address_column[flag_index]] != 4'b0) || (in_reg[blank_address_column[flag_index]] == in_reg[blank_address_column[flag_index]+4] && in_reg[blank_address_column[flag_index]] != 4'b0)  ||
                      (in_reg[blank_address_column[flag_index]] == in_reg[blank_address_column[flag_index]+5] && in_reg[blank_address_column[flag_index]] != 4'b0) || (in_reg[blank_address_column[flag_index]] == in_reg[blank_address_column[flag_index]+6] && in_reg[blank_address_column[flag_index]] != 4'b0)  ||   
                      (in_reg[blank_address_column[flag_index]] == in_reg[blank_address_column[flag_index]+7] && in_reg[blank_address_column[flag_index]] != 4'b0) || (in_reg[blank_address_column[flag_index]] == in_reg[blank_address_column[flag_index]+8] && in_reg[blank_address_column[flag_index]] != 4'b0)  ||

                      (in_reg[blank_address_column[flag_index]+1] == in_reg[blank_address_column[flag_index]+2] && in_reg[blank_address_column[flag_index]+1] != 4'b0) || (in_reg[blank_address_column[flag_index]+1] == in_reg[blank_address_column[flag_index]+3] && in_reg[blank_address_column[flag_index]+1] != 4'b0)  ||
                      (in_reg[blank_address_column[flag_index]+1] == in_reg[blank_address_column[flag_index]+4] && in_reg[blank_address_column[flag_index]+1] != 4'b0) || (in_reg[blank_address_column[flag_index]+1] == in_reg[blank_address_column[flag_index]+5] && in_reg[blank_address_column[flag_index]+1] != 4'b0)  ||
                      (in_reg[blank_address_column[flag_index]+1] == in_reg[blank_address_column[flag_index]+6] && in_reg[blank_address_column[flag_index]+1] != 4'b0) || (in_reg[blank_address_column[flag_index]+1] == in_reg[blank_address_column[flag_index]+7] && in_reg[blank_address_column[flag_index]+1] != 4'b0)  ||
                      (in_reg[blank_address_column[flag_index]+1] == in_reg[blank_address_column[flag_index]+8] && in_reg[blank_address_column[flag_index]+1] != 4'b0) ||
    
                      (in_reg[blank_address_column[flag_index]+2] == in_reg[blank_address_column[flag_index]+3] && in_reg[blank_address_column[flag_index]+2] != 4'b0) || (in_reg[blank_address_column[flag_index]+2] == in_reg[blank_address_column[flag_index]+4] && in_reg[blank_address_column[flag_index]+2] != 4'b0)  ||
                      (in_reg[blank_address_column[flag_index]+2] == in_reg[blank_address_column[flag_index]+5] && in_reg[blank_address_column[flag_index]+2] != 4'b0) || (in_reg[blank_address_column[flag_index]+2] == in_reg[blank_address_column[flag_index]+6] && in_reg[blank_address_column[flag_index]+2] != 4'b0)  ||
                      (in_reg[blank_address_column[flag_index]+2] == in_reg[blank_address_column[flag_index]+7] && in_reg[blank_address_column[flag_index]+2] != 4'b0) || (in_reg[blank_address_column[flag_index]+2] == in_reg[blank_address_column[flag_index]+8] && in_reg[blank_address_column[flag_index]+2] != 4'b0)  ||
    
                      (in_reg[blank_address_column[flag_index]+3] == in_reg[blank_address_column[flag_index]+4] && in_reg[blank_address_column[flag_index]+3] != 4'b0) || (in_reg[blank_address_column[flag_index]+3] == in_reg[blank_address_column[flag_index]+5] && in_reg[blank_address_column[flag_index]+3] != 4'b0)  ||
                      (in_reg[blank_address_column[flag_index]+3] == in_reg[blank_address_column[flag_index]+6] && in_reg[blank_address_column[flag_index]+3] != 4'b0) || (in_reg[blank_address_column[flag_index]+3] == in_reg[blank_address_column[flag_index]+7] && in_reg[blank_address_column[flag_index]+3] != 4'b0)  ||
                      (in_reg[blank_address_column[flag_index]+3] == in_reg[blank_address_column[flag_index]+8] && in_reg[blank_address_column[flag_index]+3] != 4'b0) || 
    
                      (in_reg[blank_address_column[flag_index]+4] == in_reg[blank_address_column[flag_index]+5] && in_reg[blank_address_column[flag_index]+4] != 4'b0) || (in_reg[blank_address_column[flag_index]+4] == in_reg[blank_address_column[flag_index]+6] && in_reg[blank_address_column[flag_index]+4] != 4'b0)  ||
                      (in_reg[blank_address_column[flag_index]+4] == in_reg[blank_address_column[flag_index]+7] && in_reg[blank_address_column[flag_index]+4] != 4'b0) || (in_reg[blank_address_column[flag_index]+4] == in_reg[blank_address_column[flag_index]+8] && in_reg[blank_address_column[flag_index]+4] != 4'b0)  ||

                      (in_reg[blank_address_column[flag_index]+5] == in_reg[blank_address_column[flag_index]+6] && in_reg[blank_address_column[flag_index]+5] != 4'b0) || (in_reg[blank_address_column[flag_index]+5] == in_reg[blank_address_column[flag_index]+7] && in_reg[blank_address_column[flag_index]+5] != 4'b0)  ||
                      (in_reg[blank_address_column[flag_index]+5] == in_reg[blank_address_column[flag_index]+8] && in_reg[blank_address_column[flag_index]+5] != 4'b0) || 

                      (in_reg[blank_address_column[flag_index]+6] == in_reg[blank_address_column[flag_index]+7] && in_reg[blank_address_column[flag_index]+6] != 4'b0) || (in_reg[blank_address_column[flag_index]+6] == in_reg[blank_address_column[flag_index]+8] && in_reg[blank_address_column[flag_index]+6] != 4'b0)  ||

                      (in_reg[blank_address_column[flag_index]+7] == in_reg[blank_address_column[flag_index]+8] && in_reg[blank_address_column[flag_index]+7] != 4'b0))? 1'b0: 1'b1;

//-- grid_flag
assign grid_flag = ((in_reg[blank_address_grid[flag_index]] == in_reg[blank_address_grid[flag_index]+1] && in_reg[blank_address_grid[flag_index]] != 4'b0)  || (in_reg[blank_address_grid[flag_index]] == in_reg[blank_address_grid[flag_index]+2] && in_reg[blank_address_grid[flag_index]] != 4'b0)   ||
                    (in_reg[blank_address_grid[flag_index]] == in_reg[blank_address_grid[flag_index]+9] && in_reg[blank_address_grid[flag_index]] != 4'b0)  || (in_reg[blank_address_grid[flag_index]] == in_reg[blank_address_grid[flag_index]+10] && in_reg[blank_address_grid[flag_index]] != 4'b0)  ||
                    (in_reg[blank_address_grid[flag_index]] == in_reg[blank_address_grid[flag_index]+11] && in_reg[blank_address_grid[flag_index]] != 4'b0) || (in_reg[blank_address_grid[flag_index]] == in_reg[blank_address_grid[flag_index]+18] && in_reg[blank_address_grid[flag_index]] != 4'b0)  ||
                    (in_reg[blank_address_grid[flag_index]] == in_reg[blank_address_grid[flag_index]+19] && in_reg[blank_address_grid[flag_index]] != 4'b0) || (in_reg[blank_address_grid[flag_index]] == in_reg[blank_address_grid[flag_index]+20] && in_reg[blank_address_grid[flag_index]] != 4'b0)  ||
    
                    (in_reg[blank_address_grid[flag_index]+1] == in_reg[blank_address_grid[flag_index]+2] && in_reg[blank_address_grid[flag_index]+1] != 4'b0)   || (in_reg[blank_address_grid[flag_index]+1] == in_reg[blank_address_grid[flag_index]+9] && in_reg[blank_address_grid[flag_index]+1] != 4'b0)   ||
                    (in_reg[blank_address_grid[flag_index]+1] == in_reg[blank_address_grid[flag_index]+10] && in_reg[blank_address_grid[flag_index]+1] != 4'b0)  || (in_reg[blank_address_grid[flag_index]+1] == in_reg[blank_address_grid[flag_index]+11] && in_reg[blank_address_grid[flag_index]+1] != 4'b0)  ||
                    (in_reg[blank_address_grid[flag_index]+1] == in_reg[blank_address_grid[flag_index]+18] && in_reg[blank_address_grid[flag_index]+1] != 4'b0)  || (in_reg[blank_address_grid[flag_index]+1] == in_reg[blank_address_grid[flag_index]+19] && in_reg[blank_address_grid[flag_index]+1] != 4'b0)  ||
                    (in_reg[blank_address_grid[flag_index]+1] == in_reg[blank_address_grid[flag_index]+20] && in_reg[blank_address_grid[flag_index]+1] != 4'b0)  ||

                    (in_reg[blank_address_grid[flag_index]+2] == in_reg[blank_address_grid[flag_index]+9] && in_reg[blank_address_grid[flag_index]+2] != 4'b0)   || (in_reg[blank_address_grid[flag_index]+2] == in_reg[blank_address_grid[flag_index]+10] && in_reg[blank_address_grid[flag_index]+2] != 4'b0)  ||
                    (in_reg[blank_address_grid[flag_index]+2] == in_reg[blank_address_grid[flag_index]+11] && in_reg[blank_address_grid[flag_index]+2] != 4'b0)  || (in_reg[blank_address_grid[flag_index]+2] == in_reg[blank_address_grid[flag_index]+18] && in_reg[blank_address_grid[flag_index]+2] != 4'b0)  ||
                    (in_reg[blank_address_grid[flag_index]+2] == in_reg[blank_address_grid[flag_index]+19] && in_reg[blank_address_grid[flag_index]+2] != 4'b0)  || (in_reg[blank_address_grid[flag_index]+2] == in_reg[blank_address_grid[flag_index]+20] && in_reg[blank_address_grid[flag_index]+2] != 4'b0)  ||
    
                    (in_reg[blank_address_grid[flag_index]+9] == in_reg[blank_address_grid[flag_index]+10] && in_reg[blank_address_grid[flag_index]+9] != 4'b0)   || (in_reg[blank_address_grid[flag_index]+9] == in_reg[blank_address_grid[flag_index]+11] && in_reg[blank_address_grid[flag_index]+9] != 4'b0)  ||
                    (in_reg[blank_address_grid[flag_index]+9] == in_reg[blank_address_grid[flag_index]+18] && in_reg[blank_address_grid[flag_index]+9] != 4'b0)   || (in_reg[blank_address_grid[flag_index]+9] == in_reg[blank_address_grid[flag_index]+19] && in_reg[blank_address_grid[flag_index]+9] != 4'b0)  ||
                    (in_reg[blank_address_grid[flag_index]+9] == in_reg[blank_address_grid[flag_index]+20] && in_reg[blank_address_grid[flag_index]+9] != 4'b0)   || 

                    (in_reg[blank_address_grid[flag_index]+10] == in_reg[blank_address_grid[flag_index]+11] && in_reg[blank_address_grid[flag_index]+10] != 4'b0)   || (in_reg[blank_address_grid[flag_index]+10] == in_reg[blank_address_grid[flag_index]+18] && in_reg[blank_address_grid[flag_index]+10] != 4'b0)  ||
                    (in_reg[blank_address_grid[flag_index]+10] == in_reg[blank_address_grid[flag_index]+19] && in_reg[blank_address_grid[flag_index]+10] != 4'b0)   || (in_reg[blank_address_grid[flag_index]+10] == in_reg[blank_address_grid[flag_index]+20] && in_reg[blank_address_grid[flag_index]+10] != 4'b0)  ||

                    (in_reg[blank_address_grid[flag_index]+11] == in_reg[blank_address_grid[flag_index]+18] && in_reg[blank_address_grid[flag_index]+11] != 4'b0)   || (in_reg[blank_address_grid[flag_index]+11] == in_reg[blank_address_grid[flag_index]+19] && in_reg[blank_address_grid[flag_index]+11] != 4'b0)  ||
                    (in_reg[blank_address_grid[flag_index]+11] == in_reg[blank_address_grid[flag_index]+20] && in_reg[blank_address_grid[flag_index]+11] != 4'b0)   || 
    
                    (in_reg[blank_address_grid[flag_index]+18] == in_reg[blank_address_grid[flag_index]+19] && in_reg[blank_address_grid[flag_index]+18] != 4'b0)   || (in_reg[blank_address_grid[flag_index]+18] == in_reg[blank_address_grid[flag_index]+20] && in_reg[blank_address_grid[flag_index]+18] != 4'b0)  ||
    
                    (in_reg[blank_address_grid[flag_index]+19] == in_reg[blank_address_grid[flag_index]+20] && in_reg[blank_address_grid[flag_index]+19] != 4'b0))? 1'b0: 1'b1;

//-- cmp_en
assign cmp_en = (in_reg[blank_position[flag_index]] != 4'b0)? (row_flag & column_flag & grid_flag)? 1'b1: 1'b0 : 1'b0;         //1:available value  0:not available value

//-- wrong_input_en
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) wrong_input_en <= 1'b0;
    else if(next_state == IDLE) wrong_input_en <= 1'b0;
    else if(current_state == READ) begin        //if the input sudoku is wrong wrong_input_en = 1'b1
        if((row_flag & column_flag & grid_flag) == 1'b0) wrong_input_en <= 1'b1;
        else wrong_input_en <= wrong_input_en;
    end
    else wrong_input_en <= wrong_input_en;

end 

//-- flag_index
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n)  flag_index <= 4'b0;
    else if(next_state == OUT) flag_index <= 4'b0;
    else if(current_state == CALCULATE) begin
        if(cmp_en == 1'b1 && in_reg[blank_position[flag_index]] != 4'd10) begin     //if right now position equal to 10, don't plus 1 and step back to last position
            if(flag_index == 4'd14) flag_index <= 4'b0;
            else flag_index <= flag_index + 1'b1;
        end
        else if(fail_en) begin                  //if the blank position right now doesn't have any available value, step back to the last position  
            flag_index <= flag_index_backward;
        end
        else begin
            flag_index <= flag_index;
        end
    end 
    else flag_index <= flag_index;
end 


//-- flag_index_backward
assign flag_index_backward = (flag_index > 4'b0)? flag_index - 1'b1: 4'b0;      //always be flag_index - 1

//-- fail_en
assign fail_en = (in_reg[blank_position[flag_index]] == 4'd10)? 1'b1: 1'b0;




//-----------------------------------------------------------------------------------------//
/*FINITE STATE MACHINE*/

always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) current_state <= 2'b0;
    else current_state <= next_state;
end

always @(*) begin
    case (current_state)
        IDLE: begin
            if(in_valid) next_state = READ;
            else next_state = IDLE;
        end 
        READ: begin
            if(!in_valid) next_state = CALCULATE;
            else next_state = READ;
        end 
        CALCULATE: begin
            if(wrong_input_en) next_state = OUT;
            else if(in_reg[blank_position[0]] == 4'd10 || (flag_index == 4'd14 && cmp_en == 1'b1 && fail_en != 1'b1)) next_state = OUT;
            else next_state = CALCULATE;
        end     
        OUT: begin
            if(out == 4'd10 || out_reg_index == 4'd15 || wrong_input_en == 1'd1) next_state = IDLE;
            else next_state = OUT;
        end           
        default: begin
            next_state = IDLE;
        end
    endcase
end

//-----------------------------------------------------------------------------------------//
/*READ*/

//-- read in
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) begin
        for (i = 0; i < 81; i = i + 1) begin
            in_reg[i] <= 4'b0;
        end
    end
    else if(in_valid) begin
        if(in == 4'b0) in_reg[in_index] <= 4'b0;    //because the position of the blank has been recorded so here can give the value equal to 1, thus when doing compute, it can be easier to compare
        else in_reg[in_index] <= in;                
    end
    else if(current_state == IDLE) begin            //reset in IDLE state
        for (i = 0; i < 81; i = i + 1) begin
            in_reg[i] <= 4'b0;
        end        
    end
    else if(current_state == CALCULATE) begin       
        if(!cmp_en) in_reg[blank_position[flag_index]] <= in_reg[blank_position[flag_index]] + 1'b1;    //if the value  is not available, plus 1
        else if(fail_en) begin                                                                  //if the blank position right now doesn't have any available value, reset the right now position value to 0, and last position value plus 1 
            in_reg[blank_position[flag_index]] <= 4'b0;
            in_reg[blank_position[flag_index-1]] <= in_reg[blank_position[flag_index-1]] + 1'b1;
        end
        else in_reg[blank_position[flag_index]] <= in_reg[blank_position[flag_index]];
    end
    else begin
        for (i = 0; i < 81; i = i + 1) begin
            in_reg[i] <= in_reg[i];
        end
    end
end

//-- in_index
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) in_index <= 7'b0;
    else if(in_valid) begin
        in_index <= in_index + 1'b1;
    end
    else begin
        in_index <= 7'b0;
    end
end

//-- blank_position
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) begin
        for (i = 0; i < 15; i = i + 1) begin
            blank_position[i] <= 7'b0;
        end
    end 
    else if(in_valid) begin
        if(in == 4'b0) blank_position[bp_index] <= in_index;
        else blank_position[bp_index] <= blank_position[bp_index];
    end
    else begin
        for (i = 0; i < 15; i = i + 1) begin
            blank_position[i] <= blank_position[i];
        end
    end
end

//-- bp_index
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) bp_index <= 4'b0;
    else if(in_valid) begin
        if(in == 4'b0) bp_index <= bp_index + 1'b1;
        else bp_index <= bp_index;
    end
    else begin
        bp_index <= 4'b0;
    end
end

//-- row_cnt
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) row_cnt <= 4'b0;
    else if(row_cnt == 4'd8) row_cnt <= 4'b0;
    else if(in_valid) row_cnt <= row_cnt + 1'b1;
    else row_cnt <= 4'b0;
end

//-- column_cnt
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) column_cnt <= 7'b0;
    else if (current_state == IDLE) column_cnt <= 7'b0;
    else if(row_cnt == 4'd8 && in_index < 7'd80) column_cnt <= column_cnt + 7'd9;
    else column_cnt <= column_cnt;
end

//-- grid_cnt
always @(*) begin
    if(column_cnt <= 7'd18) begin
        if(row_cnt < 4'd3) grid_cnt = 6'd0;
        else if(row_cnt < 4'd6) grid_cnt = 6'd3;
        else if(row_cnt < 4'd9) grid_cnt = 6'd6;
        else grid_cnt = 6'd0;
    end
    else if(column_cnt <= 7'd45) begin
        if(row_cnt < 4'd3) grid_cnt = 6'd27;
        else if(row_cnt < 4'd6) grid_cnt = 6'd30;
        else if(row_cnt < 4'd9) grid_cnt = 6'd33;
        else grid_cnt = 6'd27;
    end
    else begin
        if(row_cnt < 4'd3) grid_cnt = 6'd54;
        else if(row_cnt < 4'd6) grid_cnt = 6'd57;
        else if(row_cnt < 4'd9) grid_cnt = 6'd60;
        else grid_cnt = 6'd54;        
    end
end

//-- blank_address_row
always @(*) begin
    if(current_state == CALCULATE) begin
        for (i = 0; i < 15; i = i + 1) begin
            blank_address_row[i] = blank_address_row_tmp[i];
        end
    end
    else begin
        blank_address_row[0] = row_cnt;
        for (i = 1; i < 15; i = i + 1) begin
            blank_address_row[i] = 4'b0;
        end
    end
end

//-- blank_address_row_tmp  //row position for in = 4'b0
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) begin
        for (i = 0; i < 15; i = i + 1) begin
            blank_address_row_tmp[i] <= 4'b0;
        end
    end
    else if(in_valid == 1'b1 && in == 4'b0) begin
        blank_address_row_tmp[ba_index] <= row_cnt;
    end
    else begin
        for (i = 0; i < 15; i = i + 1) begin
            blank_address_row_tmp[i] <= blank_address_row_tmp[i];
        end
    end
end

//-- blank_address_colume
always @(*) begin
    if(current_state == CALCULATE) begin
        for (i = 0; i < 15; i = i + 1) begin
            blank_address_column[i] = blank_address_column_tmp[i];
        end
    end
    else begin
        blank_address_column[0] = column_cnt;
        for (i = 1; i < 15; i = i + 1) begin
            blank_address_column[i] = 7'b0;
        end
    end
end

//-- blank_address_column_tmp  //column position for in = 4'b0
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) begin
        for (i = 0; i < 15; i = i + 1) begin
            blank_address_column_tmp[i] <= 7'b0;
        end
    end
    else if(in_valid == 1'b1 && in == 4'b0) begin
        blank_address_column_tmp[ba_index] <= column_cnt;
    end
    else begin
        for (i = 0; i < 15; i = i + 1) begin
            blank_address_column_tmp[i] <= blank_address_column_tmp[i];
        end
    end
end

//-- blank_address_grid
always @(*) begin
    if(current_state == CALCULATE) begin
        for (i = 0; i < 15; i = i + 1) begin
            blank_address_grid[i] = blank_address_grid_tmp[i];
        end
    end
    else begin
        blank_address_grid[0] = grid_cnt;
        for (i = 1; i < 15; i = i + 1) begin
            blank_address_grid[i] = 6'b0;
        end
    end
end

//-- blank_address_grid_tmp  //grid position for in = 4'b0
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) begin
        for (i = 0; i < 15; i = i + 1) begin
            blank_address_grid_tmp[i] <= 4'b0;
        end
    end
    else if(in_valid == 1'b1 && in == 4'b0) begin
        blank_address_grid_tmp[ba_index] <= grid_cnt;
    end
    else begin
        for (i = 0; i < 15; i = i + 1) begin
            blank_address_grid_tmp[i] <= blank_address_grid_tmp[i];
        end
    end
end

//-- ba_index
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) ba_index <= 4'b0;
    else if(in_valid == 1'b1) 
        if(in == 4'b0) ba_index <= ba_index + 1'b1;
        else ba_index <= ba_index;
    else ba_index <= 4'b0;
end

//-----------------------------------------------------------------------------------------//
/*OUTPUT*/

//-- out_valid
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) out_valid <= 1'b0;
    else if (next_state == OUT) out_valid <= 1'b1;
    else out_valid <= 1'b0;
end

//-- out_reg_index
always @(posedge clk, negedge rst_n) begin
    //#`del;
    if(!rst_n) out_reg_index <= 4'b0;
    else if (next_state == OUT) begin
        if(in_reg[blank_position[0]] == 4'b0) out_reg_index <= 4'b0;
        else out_reg_index <= out_reg_index + 1'b1;
    end
    else out_reg_index <= 4'b0;

end


//-- out
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) out <= 4'b0;
    else if(next_state == OUT) begin
        if(in_reg[blank_position[0]] == 4'b0) out <= 4'd10;
        else if (wrong_input_en) out <= 4'd10;
        else out <= in_reg[blank_position[out_reg_index]];        
    end
    else out <= 4'b0;

end

endmodule
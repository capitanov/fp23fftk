-------------------------------------------------------------------------------
--
-- Title       : FFT_logic
-- Design      : fpfftk
-- Author      : Kapitanov
-- Company     :
--
-- Description : fp23ifft_align_data
--
-- Version 1.0 : Delay correction for TWIDDLE factor and BFLYes 
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--  The MIT License (MIT)
--  Copyright (c) 2016 Kapitanov Alexander
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy 
-- of this software and associated documentation files (the "Software"), 
-- to deal in the Software without restriction, including without limitation 
-- the rights to use, copy, modify, merge, publish, distribute, sublicense, 
-- and/or sell copies of the Software, and to permit persons to whom the 
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in 
-- all copies or substantial portions of the Software.
--
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
-- IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

library work;
use work.fp_m1_pkg.fp23_complex;

entity fp23ifft_align_data is 
    generic( 
        NFFT            : integer:=16;      --! FFT lenght
        STAGE           : integer:=0;       --! FFT stage
        USE_SCALE       : boolean:=true     --! Use Taylor for twiddles
    );
    port(   
        clk             : in  std_logic;    --! Clock
        -- DATA FROM BUTTERFLY --
        ia              : in  fp23_complex; --! Input data (A)
        ib              : in  fp23_complex; --! Input data (B)
        -- DATA TO BUTTERFLY
        iax             : out fp23_complex; --! Output data (A)
        ibx             : out fp23_complex; --! Output data (B)     
        
        -- ENABLEs FROM/TO BUTTERFLY -
        bfly_en         : in  std_logic;
        bfly_enx        : out std_logic
    );
end fp23ifft_align_data;

architecture fp23ifft_align_data of fp23ifft_align_data is

begin 

ZERO_WW: if (STAGE < 2) generate
begin
    iax <= ia;
    ibx <= ib;
    bfly_enx <= bfly_en;
end generate;

LOW_WW: if ((12 > STAGE) and (1 < STAGE)) generate
    type complex_fp23xM is array (8 downto 0) of fp23_complex;
    signal iaz          : complex_fp23xM;
    signal ibz          : complex_fp23xM;
    signal ww_ena       : std_logic_vector(8 downto 0);
begin
    ww_ena <= ww_ena(7 downto 0) & bfly_en when rising_edge(clk);

    iaz <= iaz(7 downto 0) & ia when rising_edge(clk);
    ibz <= ibz(7 downto 0) & ib when rising_edge(clk);
    
    iax <= iaz(8);
    ibx <= ibz(8);
    bfly_enx <= ww_ena(8);
end generate;

MED_WW: if (11 < STAGE) generate
    X_TLR_NO: if (USE_SCALE = TRUE) generate
        type complex_fp23xM is array (8 downto 0) of fp23_complex;
        signal ww_ena       : std_logic_vector(8 downto 0);
        signal iaz          : complex_fp23xM;
        signal ibz          : complex_fp23xM;
    begin
        ww_ena <= ww_ena(7 downto 0) & bfly_en when rising_edge(clk);

        iaz <= iaz(7 downto 0) & ia when rising_edge(clk);
        ibz <= ibz(7 downto 0) & ib when rising_edge(clk);
        
        iax <= iaz(8);
        ibx <= ibz(8);
        bfly_enx <= ww_ena(8);
    end generate;

    X_TLR_YES: if (USE_SCALE = FALSE) generate
        type complex_fp23xM is array (22 downto 0) of fp23_complex;
        signal ww_ena       : std_logic_vector(22 downto 0); 
        signal iaz          : complex_fp23xM;
        signal ibz          : complex_fp23xM;
    begin
        ww_ena <= ww_ena(ww_ena'left-1 downto 0) & bfly_en when rising_edge(clk);

        iaz <= iaz(iaz'left-1 downto 0) & ia when rising_edge(clk);
        ibz <= ibz(ibz'left-1 downto 0) & ib when rising_edge(clk);
        
        iax <= iaz(iaz'left);
        ibx <= ibz(ibz'left);
        bfly_enx <= ww_ena(ww_ena'left);
    end generate;
end generate;

end fp23ifft_align_data;
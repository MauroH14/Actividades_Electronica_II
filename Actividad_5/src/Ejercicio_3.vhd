-- 1. SUMADOR
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all; -- Librería oficial estándar reemplazada aquí

entity sumador4b is
    port (a, b : in STD_LOGIC_VECTOR (3 downto 0); y : out STD_LOGIC_VECTOR (3 downto 0));
end sumador4b;

architecture estructural of sumador4b is
begin
    -- Se convierte a unsigned para sumar matemáticamente, y se vuelve a convertir a vector
    y <= std_logic_vector(unsigned(a) + unsigned(b));
end estructural;

-- 2. REGISTRO
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity registro4b is
    port (clk : in STD_LOGIC; d : in STD_LOGIC_VECTOR (3 downto 0); q : out STD_LOGIC_VECTOR (3 downto 0));
end registro4b;

architecture estructural of registro4b is
begin
    process (clk)
    begin
        if clk'event and clk = '1' then
            q <= d;
        end if;
    end process;
end estructural;

-- 3. MULTIPLEXOR
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux_control is
    port (reset, load, ending : in STD_LOGIC; d_in, sum_out, q_actual : in STD_LOGIC_VECTOR (3 downto 0); mux_out : out STD_LOGIC_VECTOR (3 downto 0));
end mux_control;

architecture estructural of mux_control is
begin
    mux_out <= "0000" when reset = '1' else
               d_in   when load = '1' else
               "0001" when (ending = '1' and q_actual = "1111") else
               sum_out when ending = '1' else
               q_actual;
end estructural;

-- 4. TOP-LEVEL
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity contador_top is
    port(clk, reset, load, ending : in STD_LOGIC; D : in STD_LOGIC_VECTOR(3 downto 0); Q : out STD_LOGIC_VECTOR(3 downto 0));
end contador_top;

architecture estructural of contador_top is
    component registro4b
        port (clk : in STD_LOGIC; d : in STD_LOGIC_VECTOR(3 downto 0); q : out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    component sumador4b
        port (a, b : in STD_LOGIC_VECTOR(3 downto 0); y : out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    component mux_control
        port (reset, load, ending : in STD_LOGIC; d_in, sum_out, q_actual : in STD_LOGIC_VECTOR(3 downto 0); mux_out : out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    
    signal sum_out_sig, mux_out_sig, Q_internal : STD_LOGIC_VECTOR(3 downto 0);
begin
    U1_SUMADOR: sumador4b port map (a => Q_internal, b => "0001", y => sum_out_sig);
    U2_MUX: mux_control port map (reset => reset, load => load, ending => ending, d_in => D, sum_out => sum_out_sig, q_actual => Q_internal, mux_out => mux_out_sig);
    U3_REGISTRO: registro4b port map (clk => clk, d => mux_out_sig, q => Q_internal);
    
    Q <= Q_internal;
end estructural;
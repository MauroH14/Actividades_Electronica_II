library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- MEMORIA DE PEATON
entity memoria_peaton is
    port(
        clk, nreset : in STD_LOGIC;
        boton       : in STD_LOGIC;
        res_ctrl    : in STD_LOGIC;
        s_out       : out STD_LOGIC
    );
end memoria_peaton;

architecture arch of memoria_peaton is
    signal estado : STD_LOGIC;
begin
    process(clk, nreset)
    begin
        if nreset = '0' then
            estado <= '0';
        elsif rising_edge(clk) then
            if res_ctrl = '1' then
                estado <= '0';
            elsif boton = '1' then
                estado <= '1';
            end if;
        end if;
    end process;
    s_out <= estado;
end arch;

-- TOP-LEVEL
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity semaforo_factorizado is
    port (
        clk      : in STD_LOGIC;
        nreset   : in STD_LOGIC;
        P_NS     : in STD_LOGIC; 
        P_EO     : in STD_LOGIC; 
        E_NS     : in STD_LOGIC; 
        E_EO     : in STD_LOGIC; 
        Z        : in STD_LOGIC; -- Bandera simulada del temporizador
        L_NS     : out STD_LOGIC_VECTOR(2 downto 0);
        L_EO     : out STD_LOGIC_VECTOR(2 downto 0)
    );
end semaforo_factorizado;

architecture estructural of semaforo_factorizado is

    signal S_NS_int, S_EO_int : STD_LOGIC;
    signal RES_NS_int, RES_EO_int, C_int : STD_LOGIC;
    signal Q_max_int : INTEGER;
    
    component semaforo_unica
        port (
            clk, nreset, S_NS, S_EO, E_NS, E_EO, Z : in STD_LOGIC;
            L_NS, L_EO : out STD_LOGIC_VECTOR(2 downto 0);
            C, RES_NS, RES_EO : out STD_LOGIC;
            Q_max : out INTEGER
        );
    end component;
begin
    -- Instancia de memoria Norte-Sur
    MEM_NS: entity work.memoria_peaton port map(
        clk => clk, nreset => nreset, boton => P_NS, res_ctrl => RES_NS_int, s_out => S_NS_int
    );

    -- Instancia de memoria Este-Oeste
    MEM_EO: entity work.memoria_peaton port map(
        clk => clk, nreset => nreset, boton => P_EO, res_ctrl => RES_EO_int, s_out => S_EO_int
    );

    -- Instancia del Controlador
    CONTROL: semaforo_unica port map(
        clk => clk, nreset => nreset,
        S_NS => S_NS_int, S_EO => S_EO_int, 
        E_NS => E_NS, E_EO => E_EO, Z => Z,
        L_NS => L_NS, L_EO => L_EO,
        C => C_int, RES_NS => RES_NS_int, RES_EO => RES_EO_int, Q_max => Q_max_int
    );
end estructural;
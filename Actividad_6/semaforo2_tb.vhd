library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity semaforo_factorizado_tb is
    -- Sin puertos
end semaforo_factorizado_tb;

architecture sim of semaforo_factorizado_tb is
    -- Componente del Top-Level
    component semaforo_factorizado
        port (
            clk      : in STD_LOGIC;
            nreset   : in STD_LOGIC;
            P_NS     : in STD_LOGIC; 
            P_EO     : in STD_LOGIC; 
            E_NS     : in STD_LOGIC; 
            E_EO     : in STD_LOGIC; 
            Z        : in STD_LOGIC;
            L_NS     : out STD_LOGIC_VECTOR(2 downto 0);
            L_EO     : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    -- Señales internas de prueba
    signal clk, P_NS, P_EO, E_NS, E_EO, Z : STD_LOGIC := '0';
    signal nreset : STD_LOGIC := '1';
    signal L_NS, L_EO : STD_LOGIC_VECTOR(2 downto 0);

begin
    -- Mapeo de puertos (sin las señales internas de control)
    dut: semaforo_factorizado port map (
        clk => clk, nreset => nreset, 
        P_NS => P_NS, P_EO => P_EO,
        E_NS => E_NS, E_EO => E_EO, 
        Z => Z, 
        L_NS => L_NS, L_EO => L_EO
    );

    -- Generador de reloj
    process begin
        clk <= '1'; wait for 5 ns;
        clk <= '0'; wait for 5 ns;
    end process;

    -- Proceso de estímulos (Idéntico al original, pero con nombres actualizados)
    process begin
        -- 0. INICIALIZACIÓN
        nreset <= '0';
        wait for 15 ns;
        nreset <= '1';
        wait for 10 ns;

        -- 1. PRUEBA BÁSICA
        Z <= '1'; wait for 10 ns; Z <= '0';
        wait for 20 ns;
        Z <= '1'; wait for 10 ns; Z <= '0';
        wait for 20 ns;
        Z <= '1'; wait for 10 ns; Z <= '0';
        wait for 20 ns;
        Z <= '1'; wait for 10 ns; Z <= '0';
        wait for 30 ns;

        -- 2. CASO PEATONAL
        P_EO <= '1'; -- Botón del peatón
        wait for 10 ns;
        Z <= '1'; wait for 10 ns; Z <= '0';
        P_EO <= '0';
        wait for 20 ns;
        Z <= '1'; wait for 10 ns; Z <= '0';
        wait for 20 ns;
        Z <= '1'; wait for 10 ns; Z <= '0';
        wait for 30 ns;

        -- 3. CASO DE EMERGENCIA
        E_EO <= '1';
        wait for 10 ns; 
        wait for 20 ns;
        Z <= '1'; wait for 10 ns; Z <= '0';
        wait for 40 ns;
        E_EO <= '0';

        assert false report "Simulacion completada exitosamente." severity failure;
    end process;

end sim;
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity semaforo_unica is
    port (
        clk      : in STD_LOGIC;
        nreset   : in STD_LOGIC; -- Reset activo en bajo
        S_NS     : in STD_LOGIC; -- Pulsador peatonal Norte-Sur
        S_EO     : in STD_LOGIC; -- Pulsador peatonal Este-Oeste
        E_NS     : in STD_LOGIC; -- Sensor Emergencia Norte-Sur
        E_EO     : in STD_LOGIC; -- Sensor Emergencia Este-Oeste
        Z        : in STD_LOGIC; -- Bandera de temporizador cumplido
        L_NS     : out STD_LOGIC_VECTOR(2 downto 0); -- Luces Norte-Sur (R, A, V)
        L_EO     : out STD_LOGIC_VECTOR(2 downto 0); -- Luces Este-Oeste (R, A, V)
        C        : out STD_LOGIC; -- Reset del temporizador
        Q_max    : out INTEGER;   -- Límite del temporizador a cargar
        RES_NS   : out STD_LOGIC; -- Reset de la memoria del botón NS
        RES_EO   : out STD_LOGIC  -- Reset de la memoria del botón EO
    );
end semaforo_unica;

architecture fsm_arch of semaforo_unica is
    type state_type is (RV, RVEXT, RA, VR, VREXT, AR);
    signal estado, estado_sig : state_type;
begin

    process (clk, nreset)
    begin
        if nreset = '0' then
            estado <= RV;
        elsif rising_edge(clk) then
            estado <= estado_sig;
        end if;
    end process;

    process (estado, Z, S_NS, S_EO, E_NS, E_EO)
    begin
        estado_sig <= estado;
        
        case estado is
            when RV =>
                -- Emergencia opuesta o tiempo cumplido sin emergencia propia
                if (Z = '1' or E_EO = '1') and S_EO = '1' and E_NS = '0' then
                    estado_sig <= RVEXT;
                elsif (Z = '1' or E_EO = '1') and S_EO = '0' and E_NS = '0' then
                    estado_sig <= RA;
                end if;
                
            when RVEXT =>
                -- Al terminar la extensión, pasa a amarillo
                if Z = '1' and E_NS = '0' then
                    estado_sig <= RA;
                end if;
                
            when RA =>
                -- Termina el amarillo y cede el paso
                if Z = '1' and E_NS = '0' then
                    estado_sig <= VR;
                end if;
                
            when VR =>
                if (Z = '1' or E_NS = '1') and S_NS = '1' and E_EO = '0' then
                    estado_sig <= VREXT;
                elsif (Z = '1' or E_NS = '1') and S_NS = '0' and E_EO = '0' then
                    estado_sig <= AR;
                end if;
                
            when VREXT =>
                if Z = '1' and E_EO = '0' then
                    estado_sig <= AR;
                end if;
                
            when AR =>
                if Z = '1' and E_EO = '0' then
                    estado_sig <= RV;
                end if;
                
            when others =>
                estado_sig <= RV;
        end case;
    end process;

    process (estado)
    begin

        C <= '0';
        Q_max <= 0;
        RES_NS <= '0';
        RES_EO <= '0';
        L_NS <= "100"; -- Rojo por defecto
        L_EO <= "100"; -- Rojo por defecto

        case estado is
            when RV =>
                C <= '1';
                Q_max <= 50;
                L_NS <= "100"; -- Rojo
                L_EO <= "001"; -- Verde
                
            when RVEXT =>
                C <= '1';
                Q_max <= 50;
                L_NS <= "100"; -- Rojo
                L_EO <= "001"; -- Verde
                RES_EO <= '1'; -- Resetea el pedido peatonal
                
            when RA =>
                C <= '1';
                Q_max <= 10;
                L_NS <= "100"; -- Rojo
                L_EO <= "010"; -- Amarillo
                
            when VR =>
                C <= '1';
                Q_max <= 50;
                L_NS <= "001"; -- Verde
                L_EO <= "100"; -- Rojo
                
            when VREXT =>
                C <= '1';
                Q_max <= 50;
                L_NS <= "001"; -- Verde
                L_EO <= "100"; -- Rojo
                RES_NS <= '1';
                
            when AR =>
                C <= '1';
                Q_max <= 10;
                L_NS <= "010"; -- Amarillo
                L_EO <= "100"; -- Rojo
        end case;
    end process;

end fsm_arch;
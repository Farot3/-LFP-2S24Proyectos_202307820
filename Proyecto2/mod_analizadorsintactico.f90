module mod_analizadorsintactico
    use mod_tokens1
    implicit none
    private
    public :: parsear1

    type(Token1), dimension(:), allocatable :: listaTokens

    integer :: numPreanalisis
    logical :: controlesProcesado = .false.
    logical :: propiedadesProcesado = .false.
    logical :: colocacionProcesado = .false.

    type(Token1) :: preanalisis

contains

    function itoa(i) result(str)
        implicit none
        integer, intent(in) :: i
        character(len=12) :: str
        write(str, '(I0)') i
    end function itoa

    ! Función del método Parea
    subroutine match(p)
        integer, intent(in) :: p
        logical :: error_encontrado
    
        error_encontrado = .false.
    
        if (preanalisis%tipos /= p) then
            if (.not. error_encontrado) then
                print *, "error de sintaxis se esperaba", getTipoTokenError(p)
                write(*, '(A)') "ERROR" // "|" // "Sintactico" // "|" // "Error sintaxis " // trim(adjustl(preanalisis%valor(1:min(len_trim(preanalisis%valor), 7)))) // "|" // "se espera " // trim(getTipoTokenError(p)) // "|" // trim(itoa(preanalisis%fila)) // "|" // trim(itoa(preanalisis%columna))
                error_encontrado = .true.
            end if
            return
        end if
    
        if (numPreanalisis < size(listaTokens)) then
            numPreanalisis = numPreanalisis + 1
            preanalisis = listaTokens(numPreanalisis)
        else
            print *, "Fin de la lista de tokens."
            stop
        end if
    end subroutine match

    ! Subrutina para verificar la secuencia de tokens
    subroutine verificarSecuencia()
        if(preanalisis%tipos == COMENTARIO_LINEA) then
            call match(COMENTARIO_LINEA)
        else if(preanalisis%tipos == COMENTARIO_MULTILINEA) then
            call match(COMENTARIO_MULTILINEA)
        end if
        call match(MENOR_QUE)       ! <
        call match(ADMIRACION)      ! !
        call match(GUION)           ! -
        call match(GUION)           ! -
        call bloqueInicio()
    end subroutine verificarSecuencia

    subroutine bloqueInicio()
        if (.not. controlesProcesado) then
            call match(nombre_bloque_Controles)  ! Controles
            controlesProcesado = .true.
            call bloqueControl()
            call FinalBLoque1()
            call verificarSecuencia()
        else if (.not. propiedadesProcesado) then
            call match(nombre_bloque_Propiedades)  ! Propiedades
            propiedadesProcesado = .true.
            call bloquePropiedades()
            call FinalBLoque2()
            call verificarSecuencia()
        else if (.not. colocacionProcesado) then
            call match(nombre_bloque_Colocacion)  ! Colocacion
            colocacionProcesado = .true.
            call bloqueColocacion()
            call FinalBLoque3()
            call verificarSecuencia()
        else
            print *, "Error de sintaxis: Todos los bloques ya han sido procesados"
            stop
        end if
    end subroutine

    recursive subroutine bloqueControl()
        if(preanalisis%tipos == COMENTARIO_LINEA) then
            call match(COMENTARIO_LINEA)
            call bloqueControl()
        else if(preanalisis%tipos == COMENTARIO_MULTILINEA) then
            call match(COMENTARIO_MULTILINEA)
            call bloqueControl()
        else if(preanalisis%tipos == Palabra_clave) then
            call bloqueClave1()
        end if
    end subroutine

    recursive subroutine bloquePropiedades()
        if(preanalisis%tipos == COMENTARIO_LINEA) then
            call match(COMENTARIO_LINEA)
            call bloquePropiedades()
        else if(preanalisis%tipos == COMENTARIO_MULTILINEA) then
            call match(COMENTARIO_MULTILINEA)
            call bloquePropiedades()
        else if(preanalisis%tipos == IDENTIFICADOR) then
            call bloqueClave2()
        end if
    end subroutine

    recursive subroutine bloqueColocacion()
        if(preanalisis%tipos == COMENTARIO_LINEA) then
            call match(COMENTARIO_LINEA)
            call bloqueColocacion()
        else if(preanalisis%tipos == COMENTARIO_MULTILINEA) then
            call match(COMENTARIO_MULTILINEA)
            call bloqueColocacion()
        else if(preanalisis%tipos == IDENTIFICADOR) then
            call match(IDENTIFICADOR)
            call bloqueClave3()
        else if(preanalisis%tipos == THIS) then
            call ColoThis()
        end if
    end subroutine

    subroutine ColoThis()
        call match(THIS)
        call match(PUNTO)
        call match(ADD)
        call match(PARENTESIS_ABRE)
        call match(IDENTIFICADOR)
        call match(PARENTESIS_CIERRA)
        call match(PUNTO_Y_COMA)
        call bloqueColocacion()
    end subroutine

    subroutine bloqueClave1()
        call match(Palabra_clave)
        call match(IDENTIFICADOR)
        call match(PUNTO_Y_COMA)
        call bloqueControl()
    end subroutine

    subroutine bloqueClave2()
        call match(IDENTIFICADOR)
        call match(PUNTO)
        if(preanalisis%tipos == Propiedad_setAnto) then
            call match(Propiedad_setAnto)
            call match(PARENTESIS_ABRE)
            call match(NUMERO)
            call match(PARENTESIS_CIERRA)
            call match(PUNTO_Y_COMA)
            call bloquePropiedades()
        else if(preanalisis%tipos == Propiedad_setColorLetraFondo)then
            call match(Propiedad_setColorLetraFondo)
            call match(PARENTESIS_ABRE)
            call match(NUMERO)
            call match(COMA)
            call match(NUMERO)
            call match(COMA)
            call match(NUMERO)
            call match(PARENTESIS_CIERRA)
            call match(PUNTO_Y_COMA)
            call bloquePropiedades()
        else if(preanalisis%tipos == Propiedad_setTexto)then
            call match(Propiedad_setTexto)
            call match(PARENTESIS_ABRE)
            call match(CADENA)
            call match(PARENTESIS_CIERRA)
            call match(PUNTO_Y_COMA)
            if(preanalisis%tipos == COMENTARIO_LINEA) then
                call match(COMENTARIO_LINEA)
            else if(preanalisis%tipos == COMENTARIO_MULTILINEA) then
                call match(COMENTARIO_MULTILINEA)
            end if
            call bloquePropiedades()
        else if(preanalisis%tipos == Propiedad_setAlineacion) then
            call match(Propiedad_setAlineacion)
            call match(PARENTESIS_ABRE)
            call match(ALINEACION)
            call match(PARENTESIS_CIERRA)
            call match(PUNTO_Y_COMA)
            call bloquePropiedades()
        else if(preanalisis%tipos == Propiedad_setMarcada) then
            call match(Propiedad_setMarcada)
            call match(PARENTESIS_ABRE)
            call match(TRUE_FALSE)
            call match(PARENTESIS_CIERRA)
            call match(PUNTO_Y_COMA)
            call bloquePropiedades()
        else if(preanalisis%tipos == Propiedad_setGrupo) then
            call match(Propiedad_setGrupo)
            call match(PARENTESIS_ABRE)
            call match(IDENTIFICADOR)
            call match(PARENTESIS_CIERRA)
            call match(PUNTO_Y_COMA)
            call bloquePropiedades()
        else
            print *, "Error de sintaxis: Se esperaba una Propiedad"
        end if
        call bloquePropiedades()
    end subroutine

    subroutine  bloqueClave3()
        call match(PUNTO)
        if (preanalisis%tipos == Control_setPosicion) then
            call match(Control_setPosicion)
            call match(PARENTESIS_ABRE)
            call match(NUMERO)
            call match(COMA)
            call match(NUMERO)
            call match(PARENTESIS_CIERRA)
            call match(PUNTO_Y_COMA)
            call bloqueColocacion()
        else if(preanalisis%tipos == ADD) then
            call match(ADD)
            call match(PARENTESIS_ABRE)
            call match(IDENTIFICADOR)
            call match(PARENTESIS_CIERRA)
            call match(PUNTO_Y_COMA)
            call bloqueColocacion()
        else
            print *, "Error de sintaxis: Se esperaba una Colocacion"
        end if
    end subroutine

    subroutine FinalBLoque1()
        call match(nombre_bloque_Controles)
        call match(GUION)
        call match(GUION)
        call match(MAYOR_QUE)
        if(preanalisis%tipos == COMENTARIO_LINEA) then
            call match(COMENTARIO_LINEA)
        else if(preanalisis%tipos == COMENTARIO_MULTILINEA)then
            call match(COMENTARIO_MULTILINEA)
        end if
    end subroutine

    subroutine FinalBLoque2()
        call match(nombre_bloque_Propiedades)
        call match(GUION)
        call match(GUION)
        call match(MAYOR_QUE)
        if(preanalisis%tipos == COMENTARIO_LINEA) then
            call match(COMENTARIO_LINEA)
        else if(preanalisis%tipos == COMENTARIO_MULTILINEA)then
            call match(COMENTARIO_MULTILINEA)
        end if
    end subroutine

    subroutine FinalBLoque3()
        call match(nombre_bloque_Colocacion)
        call match(GUION)
        call match(GUION)
        call match(MAYOR_QUE)
        if(preanalisis%tipos == COMENTARIO_LINEA) then
            call match(COMENTARIO_LINEA)
        else if(preanalisis%tipos == COMENTARIO_MULTILINEA)then
            call match(COMENTARIO_MULTILINEA)
        end if
    end subroutine

    ! Subrutina para iniciar el análisis sintáctico
    subroutine parsear1(tokens)
        type(Token1), dimension(:), intent(in) :: tokens
        listaTokens = tokens
        numPreanalisis = 1
        preanalisis = listaTokens(numPreanalisis)
        call verificarSecuencia()
    end subroutine parsear1

    function getTipoTokenError(p) result(res)
        integer, intent(in) :: p
        character(len=30) :: res

        res = ""
        
        select case (p)
        case (LLAVE_ABRE)
            res = "LLAVE_ABRE"
        case (LLAVE_CIERRA)
            res = "LLAVE_CIERRA"
        case (PUNTO_Y_COMA)
            res = "PUNTO_Y_COMA"
        case (PARENTESIS_ABRE)
            res = "PARENTESIS_ABRE"
        case (PARENTESIS_CIERRA)
            res = "PARENTESIS_CIERRA"
        case (PUNTO)
            res = "PUNTO"
        case (COMA)
            res = "COMA"
        case (MENOR_QUE)
            res = "MENOR_QUE"
        case (ADMIRACION)
            res = "ADMIRACION"
        case (GUION)
            res = "GUION"
        case (MAYOR_QUE)
            res = "MAYOR_QUE"
        case (COMENTARIO_LINEA)
            res = "COMENTARIO_LINEA"
        case (COMENTARIO_MULTILINEA)
            res = "COMENTARIO_MULTILINEA"
        case (CADENA)
            res = "CADENA"
        case (NUMERO)
            res = "NUMERO"
        case (Palabra_clave)
            res = "Palabra_clave"
        case (nombre_bloque_Controles)
            res = "nombre_bloque_Controles"
        case(nombre_bloque_Propiedades)
            res = "nombre_bloque_Propiedades"
        case(nombre_bloque_Colocacion)
            res = "nombre_bloque_Colocacion"
        case (Propiedad_setColorLetraFondo)
            res = "Propiedad_setColorLetraFondo"
        case (Propiedad_setTexto)
            res = "Propiedad_setTexto"
        case (Propiedad_setAlineacion)
            res = "Propiedad_setAlineacion"
        case (Propiedad_setMarcada)
            res = "Propiedad_setMarcada"
        case (Propiedad_setGrupo)
            res = "Propiedad_setGrupo"
        case (Propiedad_setAnto)
            res = "Propiedad_setAnto"
        case (Control_setPosicion)
            res = "Control_setPosicion"
        case (IDENTIFICADOR)
            res = "IDENTIFICADOR"
        case (ADD)
            res = "ADD"
        case (THIS)
            res = "THIS"
        case default
            res = "Desconocido"
        end select
    end function getTipoTokenError

end module mod_analizadorsintactico
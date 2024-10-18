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
    ! Función del método Parea
    subroutine match(p)
        integer, intent(in) :: p
        if (preanalisis%tipos /= p) then
            print *, "Error de sintaxis: Se esperaba ", getTipoTokenError(p)
            stop
        end if
        if (numPreanalisis < size(listaTokens)) then
            numPreanalisis = numPreanalisis + 1
            preanalisis = listaTokens(numPreanalisis)
        else
            print *, "Fin de la lista de tokens."
            stop
        end if
    end subroutine match

    ! Función para verificar si un bloque ya ha sido procesado
    logical function bloqueProcesado(bloque)
        integer, intent(in) :: bloque
        select case (bloque)
        case (nombre_bloque_Controles)
            bloqueProcesado = controlesProcesado
        case (nombre_bloque_Propiedades)
            bloqueProcesado = propiedadesProcesado
        case (nombre_bloque_Colocacion)
            bloqueProcesado = colocacionProcesado
        case default
            bloqueProcesado = .false.
        end select
    end function bloqueProcesado

    ! Subrutina para verificar la secuencia de tokens
    subroutine verificarSecuencia()
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
    end subroutine

    recursive subroutine bloqueColocacion()
    end subroutine

    subroutine bloqueClave1()
        call match(Palabra_clave)
        call match(IDENTIFICADOR)
        call match(PUNTO_Y_COMA)
        call bloqueControl()
    end subroutine

    subroutine FinalBLoque1()
        call match(nombre_bloque_Controles)
        call match(GUION)
        call match(GUION)
        call match(MAYOR_QUE)
    end subroutine

    subroutine FinalBLoque2()
        call match(nombre_bloque_Propiedades)
        call match(GUION)
        call match(GUION)
        call match(MAYOR_QUE)
    end subroutine

    subroutine FinalBLoque3()
        call match(nombre_bloque_Colocacion)
        call match(GUION)
        call match(GUION)
        call match(MAYOR_QUE)
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
        case (DOS_PUNTOS)
            res = "DOS_PUNTOS"
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
        case (IGUAL)
            res = "IGUAL"
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
        case (Propiedad_setColorLetra)
            res = "Propiedad_setColorLetra"
        case (Propiedad_setTexto)
            res = "Propiedad_setTexto"
        case (Propiedad_setAlineacion)
            res = "Propiedad_setAlineacion"
        case (Propiedad_setColorFondo)
            res = "Propiedad_setColorFondo"
        case (Propiedad_setMarcada)
            res = "Propiedad_setMarcada"
        case (Propiedad_setGrupo)
            res = "Propiedad_setGrupo"
        case (Propiedad_setAncho)
            res = "Propiedad_setAncho"
        case (Propiedad_setAlto)
            res = "Propiedad_setAlto"
        case (Propiedad_setPosicion)
            res = "Propiedad_setPosicion"
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
module analizador_lexico
    implicit none
    
    type token
        character(len=1000) :: lexema
        character(len=30) :: tipo
        integer :: fila
        integer :: columna
    end type token
    
    type error
        character(len=100) :: descripcion
        character(len=1000) :: caracter_o_palabra
        integer :: fila
        integer :: columna
    end type error
    
    type pais
        character(len=100) :: nombre
        character(len=100) :: continente
        integer :: poblacion
        real :: saturacion
        character(len=200) :: bandera
    end type pais
    
    type continente
        character(len=100) :: nombre
        real :: saturacion_promedio
        integer :: num_paises
    end type continente

    type grafica
        character(len=100) :: nombre
        integer :: num_continentes
    end type grafica
    
    integer, parameter :: MAX_TOKENS = 1000
    integer, parameter :: MAX_ERRORES = 100
    integer, parameter :: MAX_PAISES = 100
    integer, parameter :: MAX_CONTINENTES = 10
    
    character(len=20), dimension(11), parameter :: palabras_reservadas = [character(len=20) :: &
        "grafica", "nombre", "continente", "pais", "poblacion", "saturacion", "bandera", ":", "{", "}", ";"]
    
    type(grafica) :: grafica_actual
    type(pais), dimension(MAX_PAISES) :: paises
    type(continente), dimension(MAX_CONTINENTES) :: continentes
    integer :: num_paises = 0
    integer :: num_continentes = 0
    
contains

subroutine analizar(entrada, tokens, num_tokens, errores, num_errores)
    character(len=*), intent(in) :: entrada
    type(token), intent(out) :: tokens(MAX_TOKENS)
    integer, intent(out) :: num_tokens
    type(error), intent(out) :: errores(MAX_ERRORES)
    integer, intent(out) :: num_errores
    
    integer :: estado, indice, fila, columna, inicio_lexema, inicio_col
    character :: c
    character(len=1000) :: lexema_actual
    logical :: procesar_actual
    
    estado = 0
    num_tokens = 0
    num_errores = 0
    fila = 1
    columna = 1
    lexema_actual = ""
    inicio_lexema = 1
    inicio_col = 1
    
    indice = 1
    do while (indice <= len_trim(entrada))
        c = entrada(indice:indice)
        procesar_actual = .true.
        
        select case (estado)
        case (0) ! Estado inicial
            inicio_lexema = fila
            inicio_col = columna
            if (c == '{' .or. c == '}' .or. c == ':' .or. c == ';') then
                call agregar_token(tokens, num_tokens, c, get_token_type(c), fila, columna)
            else if (c == '"') then
                estado = 1
                lexema_actual = c
            else if (es_letra_minuscula(c)) then
                estado = 2
                lexema_actual = c
            else if (es_digito(c)) then
                estado = 3
                lexema_actual = c
            else if (c == ' ' .or. c == char(9) .or. c == char(10)) then
                if (c == char(10)) then
                    fila = fila + 1
                    columna = 0
                end if
            else if (es_letra_mayuscula(c)) then
                call agregar_error(errores, num_errores, "Letra mayúscula no permitida", c, fila, columna)
            else
                call agregar_error(errores, num_errores, "Caracter no reconocido", c, fila, columna)
            end if
            
        case (1) ! Estado para cadenas
            lexema_actual = trim(lexema_actual) // c
            if (c == '"' .and. lexema_actual(len_trim(lexema_actual)-1:len_trim(lexema_actual)-1) /= '\') then
                call agregar_token(tokens, num_tokens, lexema_actual, "CADENA", inicio_lexema, inicio_col)
                estado = 0
                lexema_actual = ""
            else if (c == char(10)) then
                call agregar_error(errores, num_errores, "Cadena no cerrada", lexema_actual, inicio_lexema, inicio_col)
                estado = 0
                lexema_actual = ""
                fila = fila + 1
                columna = 0
            end if
            
        case (2) ! Estado para identificadores o palabras reservadas
            if (es_letra_minuscula(c) .or. es_digito(c) .or. c == '_') then
                lexema_actual = trim(lexema_actual) // c
            else
                if (es_palabra_reservada(lexema_actual)) then
                    call agregar_token(tokens, num_tokens, lexema_actual, "RESERVADA", inicio_lexema, inicio_col)
                else
                    call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR", inicio_lexema, inicio_col)
                end if
                estado = 0
                procesar_actual = .false.
            end if
            
        case (3) ! Estado para números
            if (es_digito(c)) then
                lexema_actual = trim(lexema_actual) // c
            else if (c == '%') then
                lexema_actual = trim(lexema_actual) // c
                call agregar_token(tokens, num_tokens, lexema_actual, "PORCENTAJE", inicio_lexema, inicio_col)
                estado = 0
                lexema_actual = ""
            else
                call agregar_token(tokens, num_tokens, lexema_actual, "NUMERO", inicio_lexema, inicio_col)
                estado = 0
                procesar_actual = .false.
            end if
        end select
        
        if (procesar_actual) then
            indice = indice + 1
            columna = columna + 1
        end if
    end do
    
    ! Procesar cualquier token pendiente al final de la entrada
    if (estado == 2) then
        if (es_palabra_reservada(lexema_actual)) then
            call agregar_token(tokens, num_tokens, lexema_actual, "RESERVADA", inicio_lexema, inicio_col)
        else
            call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR", inicio_lexema, inicio_col)
        end if
    else if (estado == 3) then
        call agregar_token(tokens, num_tokens, lexema_actual, "NUMERO", inicio_lexema, inicio_col)
    else if (estado == 1) then
        call agregar_error(errores, num_errores, "Cadena no cerrada al final del archivo", lexema_actual, inicio_lexema, inicio_col)
    end if
end subroutine analizar

subroutine agregar_token(tokens, num_tokens, lexema, tipo, fila, columna)
    type(token), intent(inout) :: tokens(MAX_TOKENS)
    integer, intent(inout) :: num_tokens
    character(len=*), intent(in) :: lexema, tipo
    integer, intent(in) :: fila, columna
    
    if (num_tokens < MAX_TOKENS) then
        num_tokens = num_tokens + 1
        tokens(num_tokens)%lexema = lexema
        tokens(num_tokens)%tipo = tipo
        tokens(num_tokens)%fila = fila
        tokens(num_tokens)%columna = columna
    end if
end subroutine agregar_token

subroutine agregar_error(errores, num_errores, descripcion, caracter_o_palabra, fila, columna)
    type(error), intent(inout) :: errores(MAX_ERRORES)
    integer, intent(inout) :: num_errores
    character(len=*), intent(in) :: descripcion, caracter_o_palabra
    integer, intent(in) :: fila, columna
    
    if (num_errores < MAX_ERRORES) then
        num_errores = num_errores + 1
        errores(num_errores)%descripcion = descripcion
        errores(num_errores)%caracter_o_palabra = caracter_o_palabra
        errores(num_errores)%fila = fila
        errores(num_errores)%columna = columna
    end if
end subroutine agregar_error

function get_token_type(c) result(tipo)
    character, intent(in) :: c
    character(len=20) :: tipo
    
    select case (c)
    case ('{')
        tipo = "LLAVE_ABRE"
    case ('}')
        tipo = "LLAVE_CIERRA"
    case (':')
        tipo = "DOS_PUNTOS"
    case (';')
        tipo = "PUNTO_Y_COMA"
    case default
        tipo = "DESCONOCIDO"
    end select
end function get_token_type

function es_letra_minuscula(c) result(res)
    character, intent(in) :: c
    logical :: res
    res = (c >= 'a' .and. c <= 'z')
end function es_letra_minuscula

function es_letra_mayuscula(c) result(res)
    character, intent(in) :: c
    logical :: res
    res = (c >= 'A' .and. c <= 'Z')
end function es_letra_mayuscula

function es_digito(c) result(res)
    character, intent(in) :: c
    logical :: res
    res = (c >= '0' .and. c <= '9')
end function es_digito

function es_palabra_reservada(palabra) result(res)
    character(len=*), intent(in) :: palabra
    logical :: res
    integer :: i
    res = .false.
    do i = 1, size(palabras_reservadas)
        if (trim(palabra) == trim(palabras_reservadas(i))) then
            res = .true.
            exit
        end if
    end do
end function es_palabra_reservada

subroutine generar_html(tokens, num_tokens, errores, num_errores)
    type(token), intent(in) :: tokens(MAX_TOKENS)
    integer, intent(in) :: num_tokens
    type(error), intent(in) :: errores(MAX_ERRORES)
    integer, intent(in) :: num_errores
    integer :: i, unidad
    
    open(newunit=unidad, file='resultado_analisis.html', status='replace')
    
    write(unidad, '(A)') '<!DOCTYPE html>'
    write(unidad, '(A)') '<html lang="es">'
    write(unidad, '(A)') '<head>'
    write(unidad, '(A)') '    <meta charset="UTF-8">'
    write(unidad, '(A)') '    <meta name="viewport" content="width=device-width, initial-scale=1.0">'
    write(unidad, '(A)') '    <title>Resultado del Análisis Léxico</title>'
    write(unidad, '(A)') '    <style>'
    write(unidad, '(A)') '        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }'
    write(unidad, '(A)') '        h1 { color: #333; }'
    write(unidad, '(A)') '        table { border-collapse: collapse; width: 100%; margin-top: 20px; }'
    write(unidad, '(A)') '        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }'
    write(unidad, '(A)') '        th { background-color: #f2f2f2; }'
    write(unidad, '(A)') '        .error { background-color: #ffdddd; }'
    write(unidad, '(A)') '    </style>'
    write(unidad, '(A)') '</head>'
    write(unidad, '(A)') '<body>'
    write(unidad, '(A)') '    <h1>Resultado del Análisis Léxico</h1>'
    
    if (num_errores > 0) then
        write(unidad, '(A)') '    <h2>Errores Encontrados</h2>'
        write(unidad, '(A)') '    <table>'
        write(unidad, '(A)') '        <tr><th>No</th><th>Descripción</th><th>Caracter o Palabra</th><th>Fila</th><th>Columna</th></tr>'
        do i = 1, num_errores
            write(unidad, '(A,I0,A,A,A,A,A,I0,A,I0,A)') '        <tr class="error"><td>', i, '</td><td>', &
                trim(errores(i)%descripcion), '</td><td>', trim(errores(i)%caracter_o_palabra), '</td><td>', &
                errores(i)%fila, '</td><td>', errores(i)%columna, '</td></tr>'
        end do
        write(unidad, '(A)') '    </table>'
    else
        write(unidad, '(A)') '    <h2>Tokens Identificados</h2>'
        write(unidad, '(A)') '    <table>'
        write(unidad, '(A)') '        <tr><th>No</th><th>Lexema</th><th>Tipo</th><th>Fila</th><th>Columna</th></tr>'
        do i = 1, num_tokens
            write(unidad, '(A,I0,A,A,A,A,A,I0,A,I0,A)') '        <tr><td>', i, '</td><td>', &
                trim(tokens(i)%lexema), '</td><td>', trim(tokens(i)%tipo), '</td><td>', &
                tokens(i)%fila, '</td><td>', tokens(i)%columna, '</td></tr>'
        end do
        write(unidad, '(A)') '    </table>'
    end if
    
    write(unidad, '(A)') '</body>'
    write(unidad, '(A)') '</html>'
    
    close(unidad)
end subroutine generar_html

subroutine calcular_saturacion_continentes()
    integer :: i, j
    real :: suma_saturacion
    
    do i = 1, num_continentes
        suma_saturacion = 0.0
        continentes(i)%num_paises = 0
        do j = 1, num_paises
            if (trim(paises(j)%continente) == trim(continentes(i)%nombre)) then
                suma_saturacion = suma_saturacion + paises(j)%saturacion
                continentes(i)%num_paises = continentes(i)%num_paises + 1
            end if
        end do
        if (continentes(i)%num_paises > 0) then
            continentes(i)%saturacion_promedio = suma_saturacion / continentes(i)%num_paises
        else
            continentes(i)%saturacion_promedio = 0.0
        end if
    end do
end subroutine calcular_saturacion_continentes

subroutine seleccionar_pais_menor_saturacion()
    integer :: i, indice_pais_seleccionado
    real :: menor_saturacion
    
    if (num_paises == 0) then
        print *, "Error: No hay datos suficientes para seleccionar un país."
        return
    end if
    
    menor_saturacion = paises(1)%saturacion
    indice_pais_seleccionado = 1
    
    do i = 2, num_paises
        if (paises(i)%saturacion < menor_saturacion) then
            menor_saturacion = paises(i)%saturacion
            indice_pais_seleccionado = i
        end if
    end do
    
    print *, trim(paises(indice_pais_seleccionado)%nombre) // "," // trim(adjustl(itoa(paises(indice_pais_seleccionado)%poblacion))) // "," // trim(paises(indice_pais_seleccionado)%bandera)
end subroutine seleccionar_pais_menor_saturacion

function itoa(i) result(str)
    implicit none
    integer, intent(in) :: i
    character(len=12) :: str
    write(str, '(I0)') i
end function itoa

subroutine procesar_datos(tokens, num_tokens)
    type(token), intent(in) :: tokens(MAX_TOKENS)
    integer, intent(in) :: num_tokens
    integer :: i, estado, nivel_anidamiento
    character(len=100) :: nombre_pais, nombre_continente, nombre_grafica
    integer :: poblacion
    real :: saturacion
    character(len=200) :: bandera
    
    estado = 0
    nivel_anidamiento = 0
    grafica_actual%num_continentes = 0
    do i = 1, num_tokens
        select case (estado)
        case (0) ! Esperando "grafica"
            if (tokens(i)%lexema == "grafica") then
                estado = 1
            end if
        case (1) ! Esperando "{"
            if (tokens(i)%lexema == "{") then
                nivel_anidamiento = nivel_anidamiento + 1
                estado = 2
            end if
        case (2) ! Dentro de grafica
            if (tokens(i)%lexema == "nombre") then
                estado = 3
            else if (tokens(i)%lexema == "continente") then
                grafica_actual%num_continentes = grafica_actual%num_continentes + 1
                estado = 10
            else if (tokens(i)%lexema == "}") then
                nivel_anidamiento = nivel_anidamiento - 1
                if (nivel_anidamiento == 0) then
                    estado = 0
                end if
            end if
        case (3) ! Esperando ":" después de nombre
            if (tokens(i)%lexema == ":") then
                estado = 4
            end if
        case (4) ! Esperando nombre de la gráfica
            if (tokens(i)%tipo == "CADENA") then
                nombre_grafica = tokens(i)%lexema(2:len_trim(tokens(i)%lexema)-1)
                estado = 2
            end if
        case (10) ! Esperando "{" después de continente
            if (tokens(i)%lexema == "{") then
                nivel_anidamiento = nivel_anidamiento + 1
                estado = 11
            end if
        case (11) ! Dentro de continente
            if (tokens(i)%lexema == "nombre") then
                estado = 12
            else if (tokens(i)%lexema == "pais") then
                estado = 20
            else if (tokens(i)%lexema == "}") then
                nivel_anidamiento = nivel_anidamiento - 1
                if (nivel_anidamiento == 1) then
                    estado = 2
                end if
            end if
        case (12) ! Esperando ":" después de nombre de continente
            if (tokens(i)%lexema == ":") then
                estado = 13
            end if
        case (13) ! Esperando nombre del continente
            if (tokens(i)%tipo == "CADENA") then
                nombre_continente = tokens(i)%lexema(2:len_trim(tokens(i)%lexema)-1)
                call actualizar_continente(nombre_continente, 0.0)
                estado = 11
            end if
        case (20) ! Esperando "{" después de pais
            if (tokens(i)%lexema == "{") then
                nivel_anidamiento = nivel_anidamiento + 1
                estado = 21
                nombre_pais = ""
                poblacion = 0
                saturacion = 0.0
                bandera = ""
            end if
        case (21) ! Dentro de pais
            if (tokens(i)%lexema == "nombre") then
                estado = 22
            else if (tokens(i)%lexema == "poblacion") then
                estado = 24
            else if (tokens(i)%lexema == "saturacion") then
                estado = 26
            else if (tokens(i)%lexema == "bandera") then
                estado = 28
            else if (tokens(i)%lexema == "}") then
                nivel_anidamiento = nivel_anidamiento - 1
                call agregar_pais(nombre_pais, nombre_continente, poblacion, saturacion, bandera)
                if (nivel_anidamiento == 2) then
                    estado = 11
                end if
            end if
        case (22) ! Esperando ":" después de nombre de país
            if (tokens(i)%lexema == ":") then
                estado = 23
            end if
        case (23) ! Esperando nombre del país
            if (tokens(i)%tipo == "CADENA") then
                nombre_pais = tokens(i)%lexema(2:len_trim(tokens(i)%lexema)-1)
                estado = 21
            end if
        case (24) ! Esperando ":" después de población
            if (tokens(i)%lexema == ":") then
                estado = 25
            end if
        case (25) ! Esperando valor de población
            if (tokens(i)%tipo == "NUMERO") then
                read(tokens(i)%lexema, *) poblacion
                estado = 21
            end if
        case (26) ! Esperando ":" después de saturación
            if (tokens(i)%lexema == ":") then
                estado = 27
            end if
        case (27) ! Esperando valor de saturación
            if (tokens(i)%tipo == "PORCENTAJE") then
                read(tokens(i)%lexema(1:len_trim(tokens(i)%lexema)-1), *) saturacion
                estado = 21
            end if
        case (28) ! Esperando ":" después de bandera
            if (tokens(i)%lexema == ":") then
                estado = 29
            end if
        case (29) ! Esperando ruta de la bandera
            if (tokens(i)%tipo == "CADENA") then
                bandera = tokens(i)%lexema(2:len_trim(tokens(i)%lexema)-1)
                estado = 21
            end if
        end select
    end do
    
    call calcular_saturacion_continentes()
end subroutine procesar_datos

subroutine agregar_pais(nombre, continente, poblacion, saturacion, bandera)
    character(len=*), intent(in) :: nombre, continente, bandera
    integer, intent(in) :: poblacion
    real, intent(in) :: saturacion
    
    if (num_paises < MAX_PAISES) then
        num_paises = num_paises + 1
        paises(num_paises)%nombre = nombre
        paises(num_paises)%continente = continente
        paises(num_paises)%poblacion = poblacion
        paises(num_paises)%saturacion = saturacion
        paises(num_paises)%bandera = bandera
        
        call actualizar_continente(continente, saturacion)
    else
        print *, "Error: Número máximo de países alcanzado."
    end if
end subroutine agregar_pais

subroutine actualizar_continente(nombre_continente, saturacion)
    character(len=*), intent(in) :: nombre_continente
    real, intent(in) :: saturacion
    integer :: i, indice_continente
    
    indice_continente = 0
    do i = 1, num_continentes
        if (continentes(i)%nombre == nombre_continente) then
            indice_continente = i
            exit
        end if
    end do
    
    if (indice_continente == 0) then
        if (num_continentes < MAX_CONTINENTES) then
            num_continentes = num_continentes + 1
            continentes(num_continentes)%nombre = nombre_continente
            continentes(num_continentes)%saturacion_promedio = saturacion
            continentes(num_continentes)%num_paises = 1
        else
            print *, "Error: Número máximo de continentes alcanzado."
        end if
    else
        continentes(indice_continente)%saturacion_promedio = &
            (continentes(indice_continente)%saturacion_promedio * continentes(indice_continente)%num_paises + saturacion) / &
            (continentes(indice_continente)%num_paises + 1)
        continentes(indice_continente)%num_paises = continentes(indice_continente)%num_paises + 1
    end if
end subroutine actualizar_continente

function obtener_color(saturacion) result(color)
    real, intent(in) :: saturacion
    character(len=20) :: color
    
    if (saturacion <= 15.0) then
        color = "white"
    else if (saturacion <= 30.0) then
        color = "blue"
    else if (saturacion <= 45.0) then
        color = "green"
    else if (saturacion <= 60.0) then
        color = "yellow"
    else if (saturacion <= 75.0) then
        color = "orange"
    else
        color = "red"
    end if
end function obtener_color

end module analizador_lexico

program main
    use analizador_lexico
    implicit none
    
    character(len=10000) :: entrada
    character(len=100) :: linea
    type(token) :: tokens(MAX_TOKENS)
    type(error) :: errores(MAX_ERRORES)
    integer :: num_tokens, num_errores
    integer :: io_status
    
    entrada = ""
    
    do
        read(*, '(A)', iostat=io_status) linea
        if (io_status /= 0) exit
        entrada = trim(entrada) // trim(linea) // char(10)
    end do
    
    if (len_trim(entrada) == 0) then
        print *, "Error: No se recibió contenido para analizar."
        stop
    end if
    
    call analizar(entrada, tokens, num_tokens, errores, num_errores)
    
    if (num_errores > 0) then
        call generar_html(tokens, num_tokens, errores, num_errores)
    else
        call procesar_datos(tokens, num_tokens)
        call seleccionar_pais_menor_saturacion()
        call generar_html(tokens, num_tokens, errores, num_errores)
    end if
    
end program main
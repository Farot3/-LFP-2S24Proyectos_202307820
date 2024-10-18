program main
    use Analizador_lexico
    use mod_tokens
    implicit none

    character(len=10000) :: entrada
    character(len=100) :: linea
    integer :: io_status
    type(token) :: tokens(MAX_TOKENS)
    type(error) :: errores(MAX_ERRORES)
    integer :: num_tokens, num_errores

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

    if(num_errores > 0)then
        call imprimir_errores(errores, num_errores)
    else
        call imprimir_tokens(tokens, num_tokens)
        call guardar_tokens(tokens)
        call generar_html(tokens, num_tokens)
    end if
    
end program main
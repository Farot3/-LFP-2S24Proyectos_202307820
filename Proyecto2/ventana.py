import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import webbrowser

original_file_path = None
current_file_path = None


def Enviar_Datos():
    content = output_area.get("1.0", tk.END).strip()
    if not content:
        messagebox.showerror("Error", "No hay contenido para analizar.")
        return

    try:
        resultado = subprocess.run(
            ["./programa.exe"],
            input=content,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
        )

        if resultado.returncode != 0:
            raise Exception(f"Error en Fortran: {resultado.stderr}")

        output = resultado.stdout.strip()

        # Procesar el resultado del análisis
        tokens = []
        errores = []
        lines = output.split("\n")
        for line in lines:
            print(f"Procesando línea: {line}")  # Imprimir cada línea para depuración
            if line.startswith("TOKEN"):
                parts = line.split("|")
                if len(parts) >= 5:
                    tipo = parts[1].strip()
                    lexema = parts[2].strip()
                    fila = int(parts[3].strip())
                    columna = int(parts[4].strip())
                    tokens.append((tipo, lexema, fila, columna))
                else:
                    print(f"Línea de token malformada: {line}")
                    # Agregar el token malformado a la lista de tokens
                    tipo = parts[1].strip() if len(parts) > 1 else "DESCONOCIDO"
                    lexema = parts[2].strip() if len(parts) > 2 else "DESCONOCIDO"
                    fila = int(parts[3].strip()) if len(parts) > 3 else 0
                    columna = int(parts[4].strip()) if len(parts) > 4 else 0
                    tokens.append((tipo, lexema, fila, columna))
            elif line.startswith("ERROR"):
                parts = line.split("|")
                if len(parts) >= 6:
                    tipo = parts[1].strip()
                    descripcion = parts[2].strip()
                    token = parts[3].strip()
                    fila = int(parts[4].strip())
                    columna = int(parts[5].strip())
                    errores.append((tipo, fila, columna, token, descripcion))
                else:
                    print(f"Línea de error malformada: {line}")
                    # Agregar el error malformado a la lista de errores
                    tipo = parts[1].strip() if len(parts) > 1 else "DESCONOCIDO"
                    descripcion = parts[2].strip() if len(parts) > 2 else "DESCONOCIDO"
                    token = parts[3].strip() if len(parts) > 3 else "DESCONOCIDO"
                    fila = int(parts[4].strip()) if len(parts) > 4 else 0
                    columna = int(parts[5].strip()) if len(parts) > 5 else 0
                    errores.append((tipo, fila, columna, token, descripcion))

        print(f"Total de tokens encontrados: {len(tokens)}")
        print(f"Total de errores encontrados: {len(errores)}")

        if errores:
            mostrar_errores(errores)
        else:
            mostrar_tokens(tokens)
    except Exception as e:
        print(f"Error: {str(e)}")
        messagebox.showerror("Error", f"No se pudo ejecutar el análisis: {str(e)}")


def mostrar_tokens(tokens):
    limpiar_tabla()
    tabla.configure(columns=("ID", "Tipo", "Lexema", "Fila", "Columna"))
    tabla.heading("ID", text="ID", anchor="w")
    tabla.heading("Tipo", text="Tipo de Token", anchor="w")
    tabla.heading("Lexema", text="Lexema", anchor="w")
    tabla.heading("Fila", text="Fila", anchor="w")
    tabla.heading("Columna", text="Columna", anchor="w")

    for idx, token in enumerate(tokens, start=1):
        print(
            f"Insertando token en la tabla: {token}"
        )  # Imprimir token antes de insertar
        tabla.insert("", "end", values=(idx, token[0], token[1], token[2], token[3]))


def mostrar_errores(errores):
    limpiar_tabla()
    tabla.configure(columns=("ID", "Tipo", "Fila", "Columna", "Token", "Descripción"))
    tabla.heading("ID", text="ID", anchor="w")
    tabla.heading("Tipo", text="Tipo de Error", anchor="w")
    tabla.heading("Fila", text="Fila", anchor="w")
    tabla.heading("Columna", text="Columna", anchor="w")
    tabla.heading("Token", text="Token", anchor="w")
    tabla.heading("Descripción", text="Descripción", anchor="w")

    for idx, error in enumerate(errores, start=1):
        print(
            f"Insertando error en la tabla: {error}"
        )  # Imprimir error antes de insertar
        tabla.insert(
            "", "end", values=(idx, error[0], error[1], error[2], error[3], error[4])
        )


def limpiar_tabla():
    for item in tabla.get_children():
        tabla.delete(item)


def Cargar_archivo():
    global original_file_path, current_file_path
    file_path = filedialog.askopenfilename(filetypes=[("LFP files", "*.LFP")])
    if file_path:
        with open(file_path, "r") as file:
            content = file.read()
        output_area.delete("1.0", tk.END)
        output_area.insert(tk.END, content)


def Guardar():
    global original_file_path
    if original_file_path:
        # Guardar en el archivo original
        content = output_area.get("1.0", tk.END)
        with open(original_file_path, "w") as file:
            file.write(content)
        messagebox.showinfo("Guardar", "Archivo guardado exitosamente.")
    else:
        file_path = filedialog.asksaveasfilename(
            defaultextension=".LFP", filetypes=[("LFP files", "*.LFP")]
        )
        if file_path:
            # Asegurarse de que el archivo tenga la extensión .ORG
            if not file_path.endswith(".LFP"):
                file_path += ".LFP"
            original_file_path = file_path
            content = output_area.get("1.0", tk.END)
            with open(file_path, "w") as file:
                file.write(content)
            messagebox.showinfo("Guardar como", "Archivo guardado exitosamente.")


def Guardar_como():
    global original_file_path, current_file_path
    file_path = filedialog.asksaveasfilename(
        defaultextension=".LFP", filetypes=[("LFP files", "*.LFP")]
    )
    if file_path:
        # Asegurarse de que el archivo tenga la extensión .ORG
        if not file_path.endswith(".LFP"):
            file_path += ".LFP"
        current_file_path = file_path
        content = output_area.get("1.0", tk.END)
        with open(file_path, "w") as file:
            file.write(content)
        messagebox.showinfo("Guardar como", "Archivo guardado exitosamente.")


def update_cursor_position(event):
    cursor_position = output_area.index(tk.INSERT)
    line, column = cursor_position.split(".")
    cursor_position_label.config(
        text=f"Posición del cursor: Línea={line}, Columna={column}"
    )


def Salir():
    ventana.quit()


def Abrir_archivo():
    file_path = "resultado_analisis.html"
    try:
        webbrowser.open_new_tab(file_path)
        messagebox.showinfo(
            "Abrir archivo",
            f"Archivo {file_path} abierto exitosamente en el navegador.",
        )
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir el archivo: {str(e)}")


# Crear la ventana principal
ventana = tk.Tk()
ventana.title("Interfaz Tkinter con Fortran")
ventana.geometry("1450x700")

# Crear menú
menu_bar = tk.Menu(
    ventana,
    bg="#333333",
    fg="white",
    activebackground="#444444",
    activeforeground="white",
)
ventana.config(menu=menu_bar)

menu_opciones = tk.Menu(menu_bar, tearoff=0, bg="#333333", fg="white")
menu_bar.add_cascade(label="Archivo", menu=menu_opciones)
menu_bar.add_cascade(label="Analisis", command=Enviar_Datos)
menu_bar.add_cascade(label="Tokens", command=Abrir_archivo)

menu_opciones.add_command(label="Nuevo")
menu_opciones.add_command(label="Abrir", command=Cargar_archivo)
menu_opciones.add_separator()
menu_opciones.add_command(label="Guardar", command=Guardar)
menu_opciones.add_command(label="Guardar como", command=Guardar_como)
menu_opciones.add_separator()
menu_opciones.add_command(label="Salir", command=Salir)

# Crear notebook
notebook = tk.Frame(ventana, bg="#262626")
notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

# Crear frames principales
left_frame = tk.Frame(
    notebook, width=400, height=500, relief=tk.SUNKEN, bd=1, bg="#1a1a1a"
)
left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5, pady=5)

right_frame = tk.Frame(ventana, width=500, height=500)
right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=5, pady=5)

# Crear un frame para el output_area y el label
output_frame = tk.Frame(left_frame, bg="#1a1a1a")
output_frame.pack(fill=tk.BOTH, expand=True, anchor="n")

# Elementos en el frame izquierdo
output_area = tk.Text(output_frame, height=25, width=100, bg="#333333", fg="white")
output_area.pack(side=tk.LEFT, anchor="n")

cursor_position_label = tk.Label(
    output_frame,
    text="Posición del cursor: Línea=1, Columna=0",
    bg="red",
    fg="white",
    relief=tk.RAISED,
    bd=2,
)
cursor_position_label.pack(side=tk.LEFT, padx=5, anchor="n")

# Vincular el evento <KeyRelease> al output_area para actualizar la posición del cursor
output_area.bind("<KeyRelease>", update_cursor_position)
output_area.bind("<ButtonRelease>", update_cursor_position)

# Crear tabla en el frame derecho
tabla = ttk.Treeview(right_frame)
tabla.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

# Configurar columnas y encabezados predeterminados
tabla.configure(columns=("ID", "Tipo", "Lexema", "Fila", "Columna"))
tabla.heading("ID", text="ID", anchor="w")
tabla.heading("Tipo", text="Tipo de Token", anchor="w")
tabla.heading("Lexema", text="Lexema", anchor="w")
tabla.heading("Fila", text="Fila", anchor="w")
tabla.heading("Columna", text="Columna", anchor="w")

# Configurar scrollbars para la tabla
scrollbar_y = ttk.Scrollbar(right_frame, orient="vertical", command=tabla.yview)
scrollbar_y.pack(side=tk.RIGHT, fill=tk.Y)
tabla.configure(yscrollcommand=scrollbar_y.set)

scrollbar_x = ttk.Scrollbar(right_frame, orient="horizontal", command=tabla.xview)
scrollbar_x.pack(side=tk.BOTTOM, fill=tk.X)
tabla.configure(xscrollcommand=scrollbar_x.set)

# Ejecutar la ventana
ventana.mainloop()

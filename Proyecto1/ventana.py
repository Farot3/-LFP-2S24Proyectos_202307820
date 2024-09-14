import tkinter as tk
import subprocess
from tkinter import messagebox
from tkinter import filedialog


def load_file():
    file_path = filedialog.askopenfilename(filetypes=[("ORG files", "*.ORG")])
    if file_path:
        with open(file_path, "r") as file:
            content = file.read()
        output_area.delete("1.0", tk.END)
        output_area.insert(tk.END, content)


def Enviar_Datos():
    content = output_area.get("1.0", tk.END)
    if not content.strip():
        messagebox.showerror("Error", "No hay contenido para analizar.")
        return

    try:
        resultado = subprocess.run(
            ["./analisis.exe"],
            input=content,  # Enviar el dato como cadena de texto
            stdout=subprocess.PIPE,  # Capturar la salida del programa
            text=True,
        )

        # Print Fortran output for debugging
        print("Salida del programa Fortran:")
        print(resultado.stdout)

        if resultado.stderr:
            print("Error del programa Fortran:")
            print(resultado.stderr)

        # Process Fortran output
        lines = resultado.stdout.strip().split("\n")

        # Display tokens in the output area
        output_area.delete("1.0", tk.END)
        output_area.insert(tk.END, "Tokens Identificados:\n")
        for line in lines:
            if line.startswith("TOKEN:"):
                _, lexema, tipo, fila, columna = line.split(",")
                output_area.insert(
                    tk.END,
                    f"Lexema: {lexema}, Tipo: {tipo}, Fila: {fila}, Columna: {columna}\n",
                )

        messagebox.showinfo(
            "Proceso completado",
            "El análisis léxico ha sido completado. Revisa el área de salida para ver los resultados.",
        )

    except Exception as e:
        print(f"Error: No se pudo ejecutar el programa Fortran: {str(e)}")
        messagebox.showerror(
            "Error", f"No se pudo ejecutar el programa Fortran: {str(e)}"
        )


def save_file():
    file_path = filedialog.asksaveasfilename(
        defaultextension=".ORG", filetypes=[("ORG files", "*.ORG")]
    )
    if file_path:
        content = output_area.get("1.0", tk.END)
        with open(file_path, "w") as file:
            file.write(content)
        messagebox.showinfo("Guardar", "Archivo guardado exitosamente.")


def exit_app():
    ventana.quit()


def Datos_estudiantes():
    messagebox.showinfo(
        "Datos", "Ottoniel Fabricio Vásquez Pineda, 202307820, LFP, sección B+"
    )


# Crear la ventana principal
ventana = tk.Tk()
ventana.title("Interfaz Tkinter con Fortran")
ventana.geometry("800x600")

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
menu_bar.add_cascade(label="Menú", menu=menu_opciones)
menu_bar.add_cascade(label="Acerca de", command=Datos_estudiantes)
menu_bar.add_cascade(label="Salir", command=exit_app)

menu_opciones.add_command(label="Abrir", command=load_file)
menu_opciones.add_separator()
menu_opciones.add_command(label="Guardar", command=save_file)
menu_opciones.add_command(label="Guardar como", command=save_file)

# Crear notebook
notebook = tk.Frame(ventana, bg="#262626")
notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

tab_label = tk.Label(
    notebook, text="Para analizar datos", relief=tk.RIDGE, bg="#333333", fg="white"
)
tab_label.pack(side=tk.TOP, anchor=tk.W, pady=5)

# Crear frames principales
left_frame = tk.Frame(
    notebook, width=400, height=500, relief=tk.SUNKEN, bd=1, bg="#1a1a1a"
)
left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5, pady=5)

right_frame = tk.Frame(
    notebook, width=400, height=500, relief=tk.SUNKEN, bd=1, bg="#1a1a1a"
)
right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=5, pady=5)

# Elementos en el frame izquierdo
output_area = tk.Text(left_frame, height=25, width=40, bg="#333333", fg="white")
output_area.pack(pady=10)

tk.Button(
    left_frame,
    text="Analizar",
    command=Enviar_Datos,
    bg="#990000",
    fg="white",
).pack(pady=5)

# Elementos en el frame derecho
label_tipo_grafica = tk.Label(
    right_frame, text="Gráfica", font=("Arial", 12), bg="#1a1a1a", fg="#ff6666"
)
label_tipo_grafica.pack(side=tk.TOP, pady=10)

# Simulación de árbol en el canvas
tree_canvas = tk.Canvas(right_frame, width=380, height=300, bg="#262626")
tree_canvas.pack(pady=10)

# Información del país
info_frame = tk.Frame(right_frame, bg="#1a1a1a")
info_frame.pack(side=tk.BOTTOM, fill=tk.X, pady=10)

# Colocación de las etiquetas a la izquierda
label_info_frame = tk.Frame(info_frame, bg="#1a1a1a")
label_info_frame.pack(side=tk.LEFT, fill=tk.X)

label_nombre = tk.Label(
    label_info_frame, text="País seleccionado: ", bg="#1a1a1a", fg="white"
)
label_nombre.pack(anchor="w")

label_poblacion = tk.Label(
    label_info_frame, text="Población: ", bg="#1a1a1a", fg="white"
)
label_poblacion.pack(anchor="w")

# Colocación de la imagen a la derecha
label_bandera = tk.Label(info_frame, bg="#1a1a1a")
label_bandera.pack(side=tk.RIGHT, padx=10)

# Ejecutar la ventana
ventana.mainloop()

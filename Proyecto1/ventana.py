import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox


def load_file():
    file_path = filedialog.askopenfilename(filetypes=[("ORG files", "*.ORG")])
    if file_path:
        with open(file_path, "r") as file:
            content = file.read()
        output_area.delete("1.0", tk.END)
        output_area.insert(tk.END, content)


def Enviar_Datos():
    content = output_area.get("1.0", tk.END).strip()
    if not content:
        messagebox.showerror("Error", "No hay contenido para analizar.")
        return

    try:
        # Ejecutar el programa Fortran y enviar el contenido
        resultado = subprocess.run(
            [
                "./analisis.exe"
            ],  # Asegúrate de que este es el nombre correcto de tu ejecutable Fortran
            input=content,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
        )

        if resultado.returncode != 0:
            raise Exception(f"Error en Fortran: {resultado.stderr}")

        # Procesar la salida
        lineas_salida = resultado.stdout.strip().split("\n")
        if len(lineas_salida) >= 3:
            mensaje = f"Análisis completado.\nTokens identificados: {lineas_salida[1]}\nErrores encontrados: {lineas_salida[2]}"
            output_area.insert(tk.END, mensaje + "\n")

            messagebox.showinfo("Proceso completado", mensaje)
        else:
            raise Exception("La salida de Fortran no tiene el formato esperado")

    except Exception as e:
        print(f"{str(e)}")
        messagebox.showerror("Error", f"No se pudo ejecutar el análisis: {str(e)}")


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
import tkinter as tk # Para crear la interfaz gráfica
from tkinter import ttk # Para usar el widget Combobox
from tkinter import messagebox # Para mostrar mensajes emergentes
import serial 
import threading # Para manejar hilos
import time

# Inicializamos la ventana principal
main_window = tk.Tk()
main_window.geometry('300x250')  
main_window.title("CALCULATOR ALU-UART")
main_window.config(background="#f0f0f0")
main_window.resizable(False, False)

# Definimos una clase para los flags de conexión
class Flags:
    connected: bool
    not_gud: bool # Indica si ha habido un problema en la lectura

# Inicializamos los flags
flags = Flags()
flags.connected = False
flags.not_gud = False

# Definimos una clase para el hilo de lectura del puerto serie
class SerialThread(threading.Thread):
    def __init__(self, thread_name, thread_ID):
        threading.Thread.__init__(self) # Inicializamos el hilo
        self.thread_name = thread_name
        self.thread_ID = thread_ID

    def run(self):
        # Método que se ejecutará cuando el hilo inicie
        while True:
            if ser.inWaiting():
                if not flags.not_gud:
                    flags.not_gud = True # Indicamos que hemos tenido un problema
                else:
                    # Leemos un byte del puerto serie
                    received = int.from_bytes(ser.readline(), byteorder='big') & 0xFF
                    # Mostramos el resultado en la etiqueta
                    result_frame.config(text=received)

# Función para conectar al puerto serie
def connect():
    if flags.connected:
        messagebox.showinfo("Aviso", "Ya se encuentra conectado")
        return
    try:
        global ser # Definimos 'ser' como global para acceder en otras funciones
        ser = serial.Serial(port_entry.get(), 38400, 8, timeout=1)  # Inicializamos la conexión sino probar 38400
    except serial.SerialException:
        messagebox.showinfo("Error de conexión", "Hay un problema con el puerto serie")
        return
    else:
        messagebox.showinfo("Aviso", "Conexión establecida exitosamente.")
        flags.connected = True # Marcamos que estamos conectados
        global serial_thread
        serial_thread = SerialThread("SERIAL_THREAD", "666")
        serial_thread.start()
        # Enviamos un byte 'b' mientras no haya problemas
        while not flags.not_gud:
            ser.write(b'b')
            time.sleep(0.2)

# Función para enviar datos
def send():
    if not flags.connected:  # Verificamos si estamos conectados
        messagebox.showinfo("Error de conexión", 'Primero hay que conectarse al puerto serie')
        return
    try:
         # Leemos los datos de las entradas
        dato_a = int(datoA_entry.get())
        dato_b = int(datoB_entry.get())

        # Comprobamos que los datos estén en el rango correcto (0-255)
        if not (0 <= dato_a <= 255) or not (0 <= dato_b <= 255):
            messagebox.showinfo("Problema con los inputs", "Los inputs no pueden ser mayores que 255")
            return
        
        # Convertimos los datos a bytes
        dA = dato_a.to_bytes(1, "big")
        dB = dato_b.to_bytes(1, "big")
        dO = get_opcode(opcode_list.get()) # Obtenemos el opcode seleccionado

        dFull = dA + dB + dO # Concatenamos los datos
        
        ser.write(dFull) # Enviamos los datos al puerto serie
        
    except ValueError:
        messagebox.showinfo("Error de entrada", "Por favor, ingrese valores válidos para Dato A y Dato B.")
    except serial.SerialException:
        messagebox.showinfo("Error de conexión", "Hubo un problema con el puerto serie")

# Función para obtener el opcode según la selección
def get_opcode(opcode_string):
    opcodes = {
       "ADD": b'\x20',
        "SUB": b'\x22',
        "AND": b'\x24',
        "OR": b'\x25',
        "XOR": b'\x26',
        "NOR": b'\x27',
        "SRL": b'\x02',
        "SRA": b'\x03',
    }
    return opcodes.get(opcode_string, b'\x68')  # Default to 'NOP'

# Elementos de la interfaz
port_label = tk.Label(main_window, text="Puerto COM:", background="#f0f0f0", font=("Arial", 10))
port_label.place(x=20, y=20)
port_entry = tk.Entry(main_window, width=10, font=("Arial", 10))
port_entry.place(x=100, y=20)
port_entry.insert(tk.END, "COM7")

# Botón para conectar
connect_button = tk.Button(main_window, text="Conectar", command=connect, font=("Arial", 10), bg="#4CAF50", fg="white")
connect_button.place(x=200, y=15)

# Etiqueta y entrada para Dato A
datoA_label = tk.Label(main_window, text="Dato A (0-255):", background="#f0f0f0", font=("Arial", 10))
datoA_label.place(x=20, y=60)
datoA_entry = tk.Entry(main_window, width=10, font=("Arial", 10))
datoA_entry.place(x=20, y=90)

# Etiqueta y entrada para Dato B
datoB_label = tk.Label(main_window, text="Dato B (0-255):", background="#f0f0f0", font=("Arial", 10))
datoB_label.place(x=150, y=60)
datoB_entry = tk.Entry(main_window, width=10, font=("Arial", 10))
datoB_entry.place(x=150, y=90)

# Etiqueta para el opcode
opcode_label = tk.Label(main_window, text="Opcode:", background="#f0f0f0", font=("Arial", 10))
opcode_label.place(x=20, y=130)

opcode_list = ttk.Combobox(main_window, state="readonly", values=["ADD", "SUB", "AND", "OR", "XOR", "NOR", "SRL", "SRA"], width=5)
opcode_list.place(x=80, y=130)

# Botón para enviar los datos
send_button = tk.Button(main_window, text="Enviar", command=send, font=("Arial", 12), bg="#2196F3", fg="white")
send_button.place(x=150, y=130)

# Etiqueta para mostrar el resultado
result_label = tk.Label(main_window, text="Resultado:", background="#f0f0f0", font=("Arial", 10))
result_label.place(x=20, y=170)
result_frame = tk.Label(main_window, bg="white", relief=tk.SUNKEN, bd=2, width=15, height=2)
result_frame.place(x=100, y=170)

# Iniciamos el bucle principal de la interfaz
main_window.mainloop()

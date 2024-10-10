import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:student_management/db_student.dart';
import 'package:student_management/models/student.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final DatabaseStudents databaseStudents = DatabaseStudents();
  List<Student> students = [];

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController generoController = TextEditingController();
  final TextEditingController gradoController = TextEditingController();
  final TextEditingController nombreTutorController = TextEditingController();
  final TextEditingController promedioCalificacionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> enviarDatos(Student student) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/students');
    final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(student.toMap()),
    );

    if (response.statusCode == 200) {
        print('Estudiante enviado a MySQL con éxito');
    } else if (response.statusCode == 400) {
        print('El estudiante ya existe: ${response.body}');
    } else {
        print('Error al enviar estudiante: ${response.body}');
    }
}


  Future<void> _syncData() async {
  List<Student> localStudents = await databaseStudents.getEstudiantes();

  for (Student student in localStudents) {
    await enviarDatos(student);
  }

  _showSuccessAlert(); // Mensaje de éxito después de sincronizar
}


  Future<void> _loadStudents() async {
    final data = await databaseStudents.getEstudiantes();
    setState(() {
      students = data;
    });
  }

  void _showForm([Student? student]) {
    if (student != null) {
      nombreController.text = student.nombre;
      edadController.text = student.edad.toString();
      correoController.text = student.correo;
      telefonoController.text = student.telefono;
      direccionController.text = student.direccion;
      generoController.text = student.genero;
      gradoController.text = student.grado;
      nombreTutorController.text = student.nombreTutor;
      promedioCalificacionController.text =
          student.promedioCalificacion.toString();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            Text(student == null ? 'Agregar estudiante' : 'Editar estudiante'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: generoController,
                decoration: const InputDecoration(labelText: 'Género'),
              ),
              TextField(
                controller: edadController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: correoController,
                decoration:
                    const InputDecoration(labelText: 'Correo Electrónico'),
              ),
              TextField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              TextField(
                controller: direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              TextField(
                controller: gradoController,
                decoration: const InputDecoration(labelText: 'Grado'),
              ),
              TextField(
                controller: nombreTutorController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del Tutor'),
              ),
              TextField(
                controller: promedioCalificacionController,
                decoration: const InputDecoration(labelText: 'Promedio (GPA)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isEmpty ||
                  edadController.text.isEmpty ||
                  correoController.text.isEmpty ||
                  telefonoController.text.isEmpty ||
                  direccionController.text.isEmpty ||
                  generoController.text.isEmpty ||
                  gradoController.text.isEmpty ||
                  nombreTutorController.text.isEmpty ||
                  promedioCalificacionController.text.isEmpty) {
                _showFieldErrorAlert();
                return;
              }

              try {
                int age = int.parse(edadController.text);
                double gpa = double.parse(promedioCalificacionController.text);

                if (student == null) {
                  await databaseStudents.insertEstudiante(Student(
                    studentId: DateTime.now().toString(),
                    nombre: nombreController.text,
                    edad: age,
                    correo: correoController.text,
                    telefono: telefonoController.text,
                    direccion: direccionController.text,
                    genero: generoController.text,
                    grado: gradoController.text,
                    nombreTutor: nombreTutorController.text,
                    fechaInscripcion: DateTime.now(),
                    promedioCalificacion: gpa,
                  ));
                } else {
                  await databaseStudents.updateEstudiante(Student(
                    id: student.id,
                    studentId: student.studentId,
                    nombre: nombreController.text,
                    edad: age,
                    correo: correoController.text,
                    telefono: telefonoController.text,
                    direccion: direccionController.text,
                    genero: generoController.text,
                    grado: gradoController.text,
                    nombreTutor: nombreTutorController.text,
                    fechaInscripcion: student.fechaInscripcion,
                    promedioCalificacion: gpa,
                  ));
                }

                Navigator.of(context).pop();
                _loadStudents();
                _showSuccessAlert();
              } catch (e) {
                _showErrorAlert();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStudent(Student student) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Confirmar eliminación',
      desc: '¿Deseas eliminar a ${student.nombre}?',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await _deleteStudent(student.id!);
      },
    ).show();
  }

  Future<void> _deleteStudent(int id) async {
    await databaseStudents.deleteEstudiante(id);
    _loadStudents();
    _showDeleteAlert();
  }

  void _showFieldErrorAlert() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Advertencia',
      desc: 'Por favor, completa todos los campos requeridos.',
      btnOkOnPress: () {},
    ).show();
  }

  void _showSuccessAlert() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Éxito',
      desc: 'Estudiante guardado con éxito',
      btnOkOnPress: () {},
    ).show();
  }



  void _showErrorAlert() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Error',
      desc: 'Error al guardar el estudiante',
      btnOkOnPress: () {},
    ).show();
  }

  void _showDeleteAlert() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Eliminado',
      desc: 'Estudiante eliminado',
      btnOkOnPress: () {},
    ).show();
  }

  void _showStudentDetails(Student student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      student.nombre[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    student.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.person, "Género", student.genero),
              _buildDetailRow(
                  Icons.calendar_today, "Edad", "${student.edad} años"),
              _buildDetailRow(Icons.email, "Correo", student.correo),
              _buildDetailRow(Icons.phone, "Teléfono", student.telefono),
              _buildDetailRow(Icons.home, "Dirección", student.direccion),
              _buildDetailRow(Icons.school, "Grado", student.grado),
              _buildDetailRow(
                  Icons.supervisor_account, "Tutor", student.nombreTutor),
              _buildDetailRow(Icons.star, "Promedio (GPA)",
                  student.promedioCalificacion.toString()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Estudiantes'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: students.isEmpty
          ? const Center(child: Text('No hay estudiantes registrados'))
          : ListView.builder(
              itemCount: students.length,
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        student.nombre[0].toUpperCase(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    title: Text(
                      student.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          "Correo: ${student.correo}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Edad: ${student.edad} años | Promedio: ${student.promedioCalificacion}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () =>
                        _showStudentDetails(student), // Añadimos esta línea
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.orangeAccent),
                          onPressed: () => _showForm(student),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _confirmDeleteStudent(student),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
     floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    FloatingActionButton(
      onPressed: () => _showForm(),
      backgroundColor: Colors.blueAccent,
      child: const Icon(Icons.add),
    ),
    SizedBox(height: 16), // Espaciado
    FloatingActionButton(
      onPressed: () => _syncData(),
      backgroundColor: Colors.green,
      child: const Icon(Icons.sync),
    ),
  ],
),
    );
  }
}

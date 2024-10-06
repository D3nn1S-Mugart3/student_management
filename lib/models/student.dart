class Student {
  int? id;
  String studentId;
  String nombre;
  int edad;
  String correo;
  String telefono;
  String direccion;
  DateTime nacimiento;
  String genero;
  String grado;
  String nombreTutor;
  DateTime fechaInscripcion;
  String notas;
  double promedioCalificacion;

  Student({
    this.id,
    required this.studentId,
    required this.nombre,
    required this.edad,
    required this.correo,
    required this.telefono,
    required this.direccion,
    required this.nacimiento,
    required this.genero,
    required this.grado,
    required this.nombreTutor,
    required this.fechaInscripcion,
    this.notas = '',
    this.promedioCalificacion = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'nombre': nombre,
      'edad': edad,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'nacimiento': nacimiento.toIso8601String(),
      'genero': genero,
      'grado': grado,
      'nombreTutor': nombreTutor,
      'fechaInscripcion': fechaInscripcion.toIso8601String(),
      'notas': notas,
      'promedioCalificacion': promedioCalificacion,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      studentId: map['studentId'],
      nombre: map['nombre'],
      edad: map['edad'],
      correo: map['correo'],
      telefono: map['telefono'],
      direccion: map['direccion'],
      nacimiento: DateTime.parse(map['nacimiento']),
      genero: map['genero'],
      grado: map['grado'],
      nombreTutor: map['nombreTutor'],
      fechaInscripcion: DateTime.parse(map['fechaInscripcion']),
      notas: map['notas'],
      promedioCalificacion: map['promedioCalificacion'],
    );
  }
}

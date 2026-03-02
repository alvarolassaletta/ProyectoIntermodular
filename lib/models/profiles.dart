class Profile{
  final String id; 
  final String? userName;
  final String? fullName; 
  final DateTime createdAt;
  final bool isAdmin; 

  Profile({
    required this.id,
    this.userName,
    this.fullName,
    required this.createdAt,
    required this.isAdmin,
  });


  factory Profile.fromMap(Map <String,dynamic> json){
    return Profile(
      // usas 
      id: json['id'] as String,
      // si llega null desde la base de datos el valor de userName sera null porque hemos usando String? . Sin esto, romperia la conversión
      userName: json['user_name'] as String?,
      fullName: json['full_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isAdmin: json['is_admin'] as bool? ?? false, 
    );
  }
  
  /* vamos a necetiar algo asi en el futuro  si se quiere actualziar el perfil 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_name': userName,
      'full_name': fullName,
      // Convertimos la fecha de Dart a un texto que Postgres entienda
      'created_at': createdAt.toIso8601String(), 
      'is_admin': isAdmin,
    };
  }
  */

}
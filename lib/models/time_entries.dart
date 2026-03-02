class TimeEntry{
  final String id;
  final  String userId;
  final DateTime clockIn; 
  final DateTime?  clockOut;
  final DateTime createdAt; 

  TimeEntry({
    required this.id,
    required this.userId,
    required this.clockIn,
    this.clockOut,
    required this.createdAt,
  }); 

  factory  TimeEntry.fromMap(Map <String,dynamic> json){
    return TimeEntry(
      id: json['id'] as String, 
      userId: json['user_id'] as String, 
      clockIn: DateTime.parse(json['clock_in'] as String),
      clockOut:  json['clock_out'] != null ? DateTime.parse(json['clock_out']  as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),

    ); 
  }

  /* vas a necetiar en el algun momento actualizar el registro ??  necesitaas algo simiarl a un toMap como en profiles */ 


 

}
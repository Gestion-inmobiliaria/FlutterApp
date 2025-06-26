import 'package:inmobiliaria_app/domain/entities/impulso_property.dart';
import 'package:inmobiliaria_app/data/sources/impulsar_property_remote_datasource.dart';
import 'package:inmobiliaria_app/domain/repository/impulsar_property_repository.dart';

class ImpulsoPropertyRepositoryImpl implements ImpulsoPropertyRepository{
 final ImpulsoPropertyRemoteDatasource remoteDatasource;

 //constructor
 ImpulsoPropertyRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<ImpulsoProperty>> getImpulsos() {
   return remoteDatasource.fetchImpulsos(); 
  } 

}
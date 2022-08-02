import 'dart:convert';
import 'dart:io';

import 'package:goport/Enums/CargoTypeEnum.dart';
import 'package:goport/Enums/GateAppStatusEnum.dart';
import 'package:goport/Models/AvailableJobs.dart';
import 'package:goport/Models/ChargeException.dart';
import 'package:goport/Models/Chassis.dart';
import 'package:goport/Models/Driver.dart';
import 'package:goport/Models/DriverGpsTracking.dart';
import 'package:goport/Models/GoPortAppStatus.dart';
import 'package:goport/Models/JobCard.dart';
import 'package:goport/Models/JobCardContainer.dart';
import 'package:goport/Models/NotTakePhotoReason.dart';
import 'package:goport/Models/Responses/EventResponse.dart';
import 'package:goport/Models/Responses/ShipResponse.dart';
import 'package:goport/Models/Responses/WarehouseResponse.dart';
import 'package:goport/Models/SaveContainersToDraft.dart';
import 'package:goport/Models/Technician.dart';
import 'package:goport/Models/ImporterChassis.dart';
import 'package:goport/Models/VehicleDetails.dart';
import 'package:goport/Models/WeightCard.dart';
import "package:http/http.dart" as http;
import 'dart:convert' as convert;

class GoPortApi {
  static final GoPortApi instance = GoPortApi();

  final baseURLTest = 'https://gpmobileapi.ashdodport.co.il';
  final baseURLProduction = 'https://gpmobileapiPrd.ashdodport.co.il';
  final baseURLBlue = 'https://go-port-webapi.emobiletest.co.il';

  String baseURL = 'https://gpmobileapiPrd.ashdodport.co.il';

  String token;

  Future<Driver> getDriver(
      String serialNumber, String tz, String serverToken) async {
    var response = await http.get(Uri.parse(
        '$baseURL/api/auth/getDriver?serialNumber=$serialNumber&tz=$tz&serverToken=$serverToken'));

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);
      final driver = Driver.fromJson(json);
      return driver;
    } else {
      return null;
    }
  }

  Future<int> getVerifyCode(String serialNumber, String tz,
      String registrationToken, String clientToken) async {
    final operatingSystemTypeID = Platform.isAndroid ? 1 : 2;
    var response = await http.get(Uri.parse(
        "$baseURL/api/auth/getVerifyCode?tz=$tz&serialNumber=$serialNumber&clientToken=$clientToken&registrationToken=$registrationToken&operatingSystemTypeID=$operatingSystemTypeID"));

    if (response.statusCode == 200) {
      final body = response.body;
      return int.parse(body);
    } else {
      return -1;
    }
  }

  Future<Driver> getDriverByVerifyCode(String serialNumber, String tz,
      String verifyCode) async {
    var response = await http.get(Uri.parse(
        "$baseURL/api/auth/getDriverByVerifyCode?tz=$tz&serialNumber=$serialNumber&verifyCode=$verifyCode"));

    if (response.statusCode == 200) {
      if (response.body == "null") {
        return null;
      } else {
        final json = convert.jsonDecode(response.body);
        final driver = Driver.fromJson(json);
        return driver;
      }
    } else {
      return null;
    }
  }

  Future<int> checkDriver(String serialNumber, String tz,
      String registrationToken, String clientToken) async {
    final operatingSystemTypeID = Platform.isAndroid ? 1 : 2;
    var response = await http.get(Uri.parse(
        "$baseURL/api/auth/checkDriver?tz=$tz&serialNumber=$serialNumber&clientToken=$clientToken&registrationToken=$registrationToken&operatingSystemTypeID=$operatingSystemTypeID"));

    if (response.statusCode == 200) {
      final body = response.body;
      return int.parse(body);
    } else {
      return -1;
    }
  }

  Future<VehicleDetails> getVehicleDetails(
      String truckNum, String tz, String trailerNum) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse(
            '$baseURL/api/truck/getVehicleDetails?truckNum=$truckNum&tz=$tz&trailerNum=$trailerNum'),
        headers: headers);

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);
      final vehicleDetails = VehicleDetails.fromJson(json);
      return vehicleDetails;
    } else {
      return null;
    }
  }

  Future<bool> checkExistsDraft(String driverTZ) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse('$baseURL/api/container/checkExistsDraft?driverTZ=$driverTZ'),
        headers: headers);

    if (response.statusCode == 200) {
      final body = response.body == "true" ? true : false;
      return body;
    } else {
      return null;
    }
  }

  Future<AvailableJobs> getAvailableJobs(
      String driverTZ, String truckNum) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse(
            '$baseURL/api/container/getAvailableJobs?driverTZ=$driverTZ&truckNum=$truckNum'),
        headers: headers);

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);
      final availableJobs = AvailableJobs.fromJson(json);
      return availableJobs;
    } else {
      return null;
    }
  }

  Future<List<Technician>> getTechnicians() async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse('$baseURL/api/container/getTechnicians'),
        headers: headers);

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);
      final technicians =
          json.map<Technician>((item) => Technician.fromJson(item)).toList();
      return technicians;
    } else {
      return [];
    }
  }

  Future<bool> addDriverGpsTracking(DriverGpsTracking driverGpsTracking) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.post(
      Uri.parse('$baseURL/api/driver/addDriverGpsTracking'),
      headers: headers,
      body: convert.jsonEncode(driverGpsTracking.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateGoPortAppStatus(GoPortAppStatus goPortAppStatus) async {
    var response = await http.post(
      Uri.parse('$baseURL/api/container/updateGoPortAppStatus'),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(goPortAppStatus.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteDriverDraftContainers(String driverTZ) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };

    var response = await http.get(Uri.parse(
        '$baseURL/api/container/deleteDriverDraftContainers?driverTZ=$driverTZ'), headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<JobCard> getJobCardContainers(String guidID) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse('$baseURL/api/container/getJobCardContainers?guidID=$guidID'),
        headers: headers);

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);
      final jobCard = JobCard.fromJson(json);
      return jobCard;
    } else {
      return null;
    }
  }

  Future<String> getJobCardGuidIDByDriver(String driverTZ) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse(
            '$baseURL/api/container/getJobCardGuidIDByDriver?driverTZ=$driverTZ'),
        headers: headers);

    if (response.statusCode == 200) {
      final cardGuid = convert.jsonDecode(response.body);
      return cardGuid;
    } else {
      return null;
    }
  }

  Future<List<String>> getImporter(String guidID) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse('$baseURL/api/chassis/getImporter?guidID=$guidID'),
        headers: headers);

    if (response.statusCode == 200) {
      return convert.jsonDecode(response.body).cast<String>();
    } else {
      return null;
    }
  }

  Future<List<String>> getLocationByImporter(
      String guidID, String importer) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse(
            '$baseURL/api/chassis/getLocationByImporter?guidID=$guidID&importer=$importer'),
        headers: headers);

    if (response.statusCode == 200) {
      return convert.jsonDecode(response.body);
    } else {
      return null;
    }
  }

  Future<List<ImporterChassis>> getChassisByImporter(
      String guidID, String importer) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse(
            '$baseURL/api/chassis/getChassisByImporter?guidID=$guidID&importer=$importer'),
        headers: headers);

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);
      final res = json
          .map((item) => ImporterChassis.fromJson(item))
          .toList()
          .cast<ImporterChassis>();

      return res;
    } else {
      return null;
    }
  }

  Future<List<Chassis>> getChassisByLocation(
      String guidID, List<ImporterChassis> locations) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.post(
        Uri.parse('$baseURL/api/chassis/getChassisByLocation?guidID=$guidID'),
        headers: headers,
        body: convert.jsonEncode(locations.map((item) => item.toJson()).toList()));

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);
      final res = json.map((item) => Chassis.fromJson(item)).toList().cast<Chassis>();
      return res;
    } else {
      return null;
    }
  }

  Future<bool> damageReporting(Chassis chassis) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.post(
      Uri.parse('$baseURL/api/chassis/damageReporting'),
      headers: headers,
      body: convert.jsonEncode(chassis.toJson()),
    );

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);
      return json;
    } else {
      return null;
    }
  }

  Future<bool> setChassisLoaded(Chassis chassis) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.post(
      Uri.parse('$baseURL/api/chassis/setChassisLoaded'),
      headers: headers,
      body: convert.jsonEncode(chassis.toJson()),
    );

    if (response.statusCode == 200) {
      final json = response.body != null && response.body == "true" ? true : false;
      return json;
    } else {
      return false;
    }
  }

  Future<bool> removeChosenChassis(int id) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse(
            '$baseURL/api/chassis/removeChosenChassis?chassisID=$id'),
        headers: headers);

    if (response.statusCode == 200) {
      return convert.jsonDecode(response.body);
    } else {
      return null;
    }
  }

  Future<EventResponse> getEvents() async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(Uri.parse('$baseURL/api/event/getEvents'),
        headers: headers);

    if (response.statusCode == 200) {
      if (response.body == "null") {
        return null;
      } else {
        final json = convert.jsonDecode(response.body);
        final res = EventResponse.fromJson(json);
        return res;
      }
    } else {
      return null;
    }
  }

  Future<ShipResponse> getShipsStatus(String driverTZ, String truckNum) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };

    var response = await http.get(Uri.parse(
        '$baseURL/api/ship/getShipsStatus?driverTZ=$driverTZ&truckNum=$truckNum'), headers: headers);

    if (response.statusCode == 200) {
      Map<String, dynamic> json = convert.jsonDecode(response.body);
      final res = ShipResponse.fromJson(json);
      return res;
    } else {
      return null;
    }
  }

  Future<WarehouseResponse> getWarehouses(
      String driverTZ, String truckNum) async {
    var response = await http.get(Uri.parse(
        '$baseURL/api/cargo/getWarehouses?driverTZ=$driverTZ&truckNum=$truckNum'));

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);
      final res = WarehouseResponse.fromJson(json);
      return res;
    } else {
      return null;
    }
  }

  Future<WeightCard> getWeightCard(String driverTZ) async {
    var response = await http
        .get(Uri.parse('$baseURL/api/cargo/getWeightCard?driverTZ=$driverTZ'));

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);
      final res = WeightCard.fromJson(json);
      return res;
    } else {
      return null;
    }
  }

  Future<bool> setGateStatus(
      String driverTZ, GateAppStatusEnum goPortStatus) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse(
            '$baseURL/api/gate/setGateStatus?driverTZ=$driverTZ&gateAppStatus=${goPortStatus.index}'),
        headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> saveContainersToDraft(
      SaveContainersToDraft saveContainersToDraft) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };

    var response = await http.post(
      Uri.parse('$baseURL/api/container/saveContainersToDraft'),
      headers: headers,
      body: convert.jsonEncode(saveContainersToDraft.toJson()),
    );

    if (response.statusCode == 200) {
      final res = response.body;
      return res;
    } else {
      return null;
    }
  }

  Future<bool> updateJobCardSeal(JobCardContainer container) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.post(
      Uri.parse('$baseURL/api/container/updateJobCardSeal'),
      headers: headers,
      body: convert.jsonEncode(container.toJson()),
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateChargeException(ChargeException chargeException) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.post(
      Uri.parse('$baseURL/api/chargeException/updateChargeException'),
      headers: headers,
      body: convert.jsonEncode(chargeException.toJson()),
    );

    if (response.statusCode == 200) {
      final res = convert.jsonDecode(response.body);
      return res;
    } else {
      return false;
    }
  }

  Future<String> getActualJobWithoutContainers(
      String driverTZ, String trailerNum, CargoTypeEnum cargoType) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse(
            '$baseURL/api/gate/getActualJobWithoutContainers?driverTZ=$driverTZ&trailerNum=$trailerNum&cargoType=$cargoType'),
        headers: headers);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  Future<bool> cancelJobCard(String driverTZ, String guidID) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse(
            '$baseURL/api/container/cancelJobCard?driverTZ=$driverTZ&guidID=$guidID'),
        headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> getDriverGuidID(String driverTZ) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse('$baseURL/api/gate/getDriverGuidID?driverTZ=$driverTZ'),
        headers: headers);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  Future<List<NotTakePhotoReason>> getNotTakePhotoReasons() async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse('$baseURL/api/container/getNotTakePhotoReasons'),
        headers: headers);

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);
      final res = json
          .map((item) => NotTakePhotoReason.fromJson(item))
          .toList()
          .cast<NotTakePhotoReason>();
      return res;
    } else {
      return null;
    }
  }

  Future<bool> checkDriverGate(String driverTZ, int gate, int status) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    };
    var response = await http.get(
        Uri.parse(
            '$baseURL/api/gate/checkDriverGate?driverTZ=$driverTZ&gate=$gate&status=$status'),
        headers: headers);

    if (response.statusCode == 200) {
      final res = convert.jsonDecode(response.body);
      return res;
    } else {
      return null;
    }
  }
}

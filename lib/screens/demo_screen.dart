// tenant_detail_screen.dart

import 'package:flutter/material.dart';

// Tenant model to represent the data
class Tenant {
  final String rid;
  final String rName;
  final String rEmail;
  final String rContact;
  final String rAddress;
  final String rFloorNo;
  final String rUnitNo;
  final String rAdvance;
  final String rRentPm;
  final String rDate;
  final String rStatus;

  Tenant({
    required this.rid,
    required this.rName,
    required this.rEmail,
    required this.rContact,
    required this.rAddress,
    required this.rFloorNo,
    required this.rUnitNo,
    required this.rAdvance,
    required this.rRentPm,
    required this.rDate,
    required this.rStatus,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      rid: json['rid'],
      rName: json['r_name'],
      rEmail: json['r_email'],
      rContact: json['r_contact'],
      rAddress: json['r_address'],
      rFloorNo: json['r_floor_no'],
      rUnitNo: json['r_unit_no'],
      rAdvance: json['r_advance'],
      rRentPm: json['r_rent_pm'],
      rDate: json['r_date'],
      rStatus: json['r_status'],
    );
  }
}

class TenantDetailScreen extends StatelessWidget {
  final Tenant tenant;

  // Constructor to accept the tenant data
  const TenantDetailScreen({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tenant Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tenant Name: ${tenant.rName}',
                  style: TextStyle(fontSize: 18)),
              Text('Email: ${tenant.rEmail}', style: TextStyle(fontSize: 16)),
              Text('Contact: ${tenant.rContact}',
                  style: TextStyle(fontSize: 16)),
              Text('Address: ${tenant.rAddress}',
                  style: TextStyle(fontSize: 16)),
              Text('Floor No: ${tenant.rFloorNo}',
                  style: TextStyle(fontSize: 16)),
              Text('Unit No: ${tenant.rUnitNo}',
                  style: TextStyle(fontSize: 16)),
              Text('Advance Payment: ${tenant.rAdvance}',
                  style: TextStyle(fontSize: 16)),
              Text('Rent Per Month: ${tenant.rRentPm}',
                  style: TextStyle(fontSize: 16)),
              Text('Lease Date: ${tenant.rDate}',
                  style: TextStyle(fontSize: 16)),
              Text('Status: ${tenant.rStatus == "1" ? "Active" : "Inactive"}',
                  style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

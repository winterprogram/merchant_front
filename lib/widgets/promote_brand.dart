import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

class PromoteBrand extends StatefulWidget {
  @override
  _PromoteBrandState createState() => _PromoteBrandState();
}

class _PromoteBrandState extends State<PromoteBrand> {
  bool _autoValidate = false;
  final _formKey = GlobalKey<FormState>();
  DateTime startdate;
  DateTime starttime;
  int amount;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Form(
            autovalidate: _autoValidate,
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: FlatButton(
                    shape: CircleBorder(),
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                  child: DateTimeField(
                    initialValue: DateTime.now(),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(Duration(days: 1)),
                          initialDate: DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'You have to specify the start date';
                      } else {
                        return null;
                      }
                    },
                    format: DateFormat("dd-MM-yyyy"),
                    decoration:
                        InputDecoration(labelText: 'Select starting date'),
                    onSaved: (value) {
                      startdate = value;
                    },
                  ),
                ),
                Container(
                  child: DateTimeField(
                    onShowPicker: (context, currentValue) async {
                      final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                      return DateTimeField.convert(time);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'You have to specify the start time';
                      } else {
                        return null;
                      }
                    },
                    format: DateFormat("hh:mm a"),
                    decoration:
                        InputDecoration(labelText: 'Select starting time'),
                    onSaved: (value) {
                      starttime = value;
                    },
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val.isEmpty) {
                      return 'Required';
                    } else {
                      return null;
                    }
                  },
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Amount',
                    labelText: 'Amount',
                  ),
                ),
                Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: RaisedButton(
                      color: kOverallColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Text('Submit'),
                      onPressed: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
                          _formKey.currentState.save();
                        } else {
                          _autoValidate = true;
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

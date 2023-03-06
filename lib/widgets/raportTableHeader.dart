import 'package:flutter/material.dart';

class ResultTableHeader extends StatelessWidget {
  const ResultTableHeader({
    Key? key,
  }) : super(key: key);

  final TextStyle _tableHeadingStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        height: 80,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 240,
              child: Text(
                "Agent Name",
                style: _tableHeadingStyle,
              ),
            ),
            Text(
              "Ward",
              style: _tableHeadingStyle,
            ),
            Text(
              "Polling Unit",
              style: _tableHeadingStyle,
            ),
            SizedBox(
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "No. Of votes Casted",
                    style: _tableHeadingStyle.copyWith(color: Colors.blue),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "PDP",
                        style: _tableHeadingStyle.copyWith(
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        "APC",
                        style: _tableHeadingStyle.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "NNPP",
                        style: _tableHeadingStyle.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Text(
              "No Violence",
              style: _tableHeadingStyle,
            ),
            SizedBox(
              width: 150,
              child: Text(
                "Result Sheet".toUpperCase(),
                style: _tableHeadingStyle,
              ),
            )
          ],
        ),
      ),
    );
  }
}

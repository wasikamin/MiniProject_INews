import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:miniproject_readapi/detail.dart';
import 'package:number_paginator/number_paginator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'I-News',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'INews'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentPage = 0;
  // instantiate the controller in your state
  final NumberPaginatorController _controller = NumberPaginatorController();

  List? data;
  var loading = false;

  Future<void> getJsonData(BuildContext context) async {
    var response = await http.get(Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=ca&page=$_currentPage&pageSize=15&apiKey=fbe06514d95345069b06efede5e06735'));
    print(response.body);
    setState(() {
      data = null;
      var convertDataToJson = jsonDecode(response.body);
      data = convertDataToJson['articles'];
    });
  }

  Future<void> _getRefreshData() async {
    setState(() async {
      loading = true;
      await this.getJsonData(context);
      loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _getRefreshData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: _getRefreshData,
        child: data == null || loading == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Expanded(
                child: Container(
                  height: double.infinity,
                  child: ListView.builder(
                    itemCount: data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == data!.length - 1) {
                        return Container(
                          child: NumberPaginator(
                            initialPage: _currentPage,
                            controller: _controller,
                            numberPages: 3,
                            onPageChange: (int i) {
                              setState(() {
                                _currentPage = i;
                                _getRefreshData();
                              });
                            },
                          ),
                        );
                      } else {
                        return Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          width: double.maxFinite,
                          child: Card(
                            elevation: 5,
                            child: Container(
                              padding: EdgeInsets.all(7),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => News(
                                                description: data![index]
                                                            ['content'] ==
                                                        null
                                                    ? data![index]
                                                        ['description']
                                                    : data![index]['content'],
                                                image: data![index]
                                                    ['urlToImage'],
                                                title: data![index]['title'],
                                                author: data![index]
                                                            ['author'] ==
                                                        null
                                                    ? "Anonim"
                                                    : data![index]['author'],
                                                date: data![index]
                                                            ['publishedAt'] ==
                                                        null
                                                    ? "-"
                                                    : data![index]
                                                        ['publishedAt'],
                                              )));
                                  ;
                                },
                                child: ListTile(
                                  leading: data![index]['urlToImage'] == null
                                      ? Image.network(
                                          "https://st3.depositphotos.com/23594922/31822/v/600/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg",
                                          width: 75,
                                        )
                                      : Image.network(
                                          data![index]['urlToImage'],
                                          width: 75,
                                        ),
                                  title: Text(data![index]['title']),
                                  subtitle: data![index]['description'] == null
                                      ? Text("")
                                      : Text(data![index]['description']),
                                  isThreeLine: true,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
      ),
    );
  }
}

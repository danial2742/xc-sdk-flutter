import 'package:cross_classify_sdk/cross_classify.dart';
import 'package:cross_classify_sdk/traceable_widgets/traceable_form_field_widget.dart';
import 'package:cross_classify_sdk/traceable_widgets/traceable_form_widget.dart';
import 'package:example/home_page.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

late final String appVersion;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enter your API Key and SiteId here!
  await CrossClassify.instance.initialize(
    apiKey: 'API_KEY_HERE',
    siteId: -1,
  );

  appVersion = (await PackageInfo.fromPlatform()).buildNumber;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginDemo(),
    );
  }
}

class LoginDemo extends StatefulWidget {
  const LoginDemo({super.key});

  @override
  createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {
  final controller1 = TextEditingController();
  final controller2 = TextEditingController();
  final focusNode1 = FocusNode();
  final focusNode2 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: TraceableForm(
        formName: 'Login',
        path: '/login',
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 60.0),
                child: Center(
                  child: FlutterLogo(size: 100),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ControllableFormFieldWidget(
                  formFieldConfig: FormFieldConfig(
                    formFieldType: 'email',
                    trackContent: true,
                    controller: controller1,
                    node: focusNode1,
                  ),
                  child: TextField(
                    controller: controller1,
                    focusNode: focusNode1,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'email',
                        hintText: 'Enter valid email id as abc@gmail.com'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: ControllableFormFieldWidget(
                  formFieldConfig: FormFieldConfig(
                    formFieldType: 'password',
                    trackContent: false,
                    controller: controller2,
                    node: focusNode2,
                  ),
                  child: TextField(
                    controller: controller2,
                    focusNode: focusNode2,
                    obscureText: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                        hintText: 'Enter secure password'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                child: ElevatedButton(
                  onPressed: () {
                    CrossClassify.instance.onFormSubmit();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HomePage()));
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(appVersion),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    super.dispose();
  }
}

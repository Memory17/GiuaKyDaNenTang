import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

//Cấu hình Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCiFzy_z_GUIohIuNsVT1ADibVkB2BPN4A",
      projectId: "quanlisanpham-449e8",
      messagingSenderId: "702720999021",
      appId: "1:702720999021:web:10bbcc3d10d09f590ac964",
    ),
  );
  runApp(MyApp());
}

// Khởi tạo giao diện ứng dụng
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Sản Phẩm',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      // Đây sẽ là màn hình chính của ứng dụng khi khởi chạy
    );
  }
}

// Màn hình đăng nhập
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Thông tin đăng nhập tĩnh
  final String _correctUsername = "admin";
  final String _correctPassword = "123456";

  // Hàm kiểm tra đăng nhập
  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == _correctUsername && password == _correctPassword) {
      // Đăng nhập thành công -> Chuyển đến trang quản lý sản phẩm
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductManagement()),
      );
    } else {
      // Đăng nhập thất bại -> Hiển thị thông báo
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Đăng nhập thất bại'),
          content: Text('Tên đăng nhập hoặc mật khẩu không đúng!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Hình nền đẹp mắt
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/login-background.jpg"), // Đường dẫn đến hình nền
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Lớp phủ mờ để làm rõ các thành phần
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tiêu đề trang đăng nhập
                  Text(
                    'Đăng Nhập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Trường nhập liệu tên đăng nhập
                  _buildTextField(
                    controller: _usernameController,
                    labelText: 'Tên đăng nhập',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 20),
                  // Trường nhập liệu mật khẩu
                  _buildTextField(
                    controller: _passwordController,
                    labelText: 'Mật khẩu',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: 30),
                  // Nút đăng nhập kiểu dáng đẹp
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm để tạo TextField với kiểu dáng đẹp hơn
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }
}

// Trang quản lý sản phẩm
class ProductManagement extends StatefulWidget {
  @override
  _ProductManagementState createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  final CollectionReference _products =
  FirebaseFirestore.instance.collection('product');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _priceController.text.isEmpty) {
      return;
    }
    await _products.add({
      'ten_san_pham': _nameController.text,
      'loai_san_pham': _typeController.text,
      'gia': double.parse(_priceController.text),
    });

    _nameController.clear();
    _typeController.clear();
    _priceController.clear();
  }

  Future<void> _updateProduct(
      String id, String name, String type, double price) async {
    await _products.doc(id).update({
      'ten_san_pham': name,
      'loai_san_pham': type,
      'gia': price,
    });
  }

  Future<void> _deleteProduct(String id) async {
    await _products.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản Lý Sản Phẩm'),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            _buildInputForm(),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Tên sản phẩm',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _typeController,
            decoration: InputDecoration(
              labelText: 'Loại sản phẩm',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Giá',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: TextStyle(fontSize: 18),
            ),
            child: Text('Thêm sản phẩm'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _products.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final products = snapshot.data!.docs;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index];

            return Card(
              margin: EdgeInsets.all(8.0),
              elevation: 5,
              child: ListTile(
                leading: Icon(Icons.shopping_cart, color: Colors.blue),
                title: Text(product['ten_san_pham']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loại: ${product['loai_san_pham']}'),
                    Text('Giá: ${product['gia']}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditDialog(
                          product.id,
                          product['ten_san_pham'],
                          product['loai_san_pham'],
                          product['gia'],
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteProduct(product.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditDialog(
      String id, String name, String type, double price) {
    _nameController.text = name;
    _typeController.text = type;
    _priceController.text = price.toString();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Cập nhật sản phẩm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên sản phẩm',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _typeController,
                  decoration: InputDecoration(
                    labelText: 'Loại sản phẩm',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Giá',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateProduct(
                  id,
                  _nameController.text,
                  _typeController.text,
                  double.parse(_priceController.text),
                );
                Navigator.of(context).pop();
              },
              child: Text('Cập nhật', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

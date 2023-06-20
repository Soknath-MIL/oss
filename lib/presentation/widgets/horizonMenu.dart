import 'package:flutter/material.dart';

class HorizontalScrollCircle extends StatefulWidget {
  const HorizontalScrollCircle({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HorizontalScrollCircleState createState() => _HorizontalScrollCircleState();
}

class _HorizontalScrollCircleState extends State<HorizontalScrollCircle> {
  final PageController _pageController =
      PageController(initialPage: 1, viewportFraction: 0.8);
  int _currentPage = 1;
  final List<Widget> _pages = [
    const Text('1'),
    const Text('2'),
    const Text('3')
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.0,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 3,
        itemBuilder: (context, index) {
          int currentPage;
          if (_currentPage == 0) {
            currentPage = _pages.length - 1;
          } else if (_currentPage == _pages.length + 1) {
            currentPage = 0;
          } else {
            currentPage = _currentPage - 1;
          }
          if (index == 0) {
            return _buildPage(currentPage - 1);
          } else if (index == 1) {
            return _buildPage(currentPage);
          } else {
            return _buildPage(currentPage + 1);
          }
        },
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
          if (index == 0) {
            _pageController.jumpToPage(_pages.length);
          } else if (index == 2) {
            _pageController.jumpToPage(1);
          }
        },
      ),
    );
  }

  Widget _buildPage(int index) {
    return Transform.scale(
      scale: 0.9,
      child: _pages[index],
    );
  }
}

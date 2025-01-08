import 'package:cornell_box/models/light.dart';
import 'package:cornell_box/models/point.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cornell_box/bloc/main_bloc.dart';

class ToolBar extends StatefulWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  State<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
  int _reflectiveWall = 4;
  bool _sphereReflective = false;
  bool _cubeReflective = true;
  bool _sphereTransparent = true;
  bool _cubeTransparent = false;
  bool _softShadows = false;
  bool _secondLight = false;
  final _lightController = TextEditingController(text: '-0.96;0;1.4');

  void _radioOnChanged(int? value) {
    if (value != null) {
      setState(() {
        _reflectiveWall = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Выбрать отражающую стену:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Radio(
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: 1,
                      groupValue: _reflectiveWall,
                      onChanged: _radioOnChanged,
                    ),
                    const SizedBox(width: 10),
                    const Text('Нет'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Radio(
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: 2,
                      groupValue: _reflectiveWall,
                      onChanged: _radioOnChanged,
                    ),
                    const SizedBox(width: 10),
                    const Text('Левая'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Radio(
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: 3,
                      groupValue: _reflectiveWall,
                      onChanged: _radioOnChanged,
                    ),
                    const SizedBox(width: 10),
                    const Text('Нижняя'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Radio(
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: 4,
                      groupValue: _reflectiveWall,
                      onChanged: _radioOnChanged,
                    ),
                    const SizedBox(width: 10),
                    const Text('Правая'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Radio(
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: 5,
                      groupValue: _reflectiveWall,
                      onChanged: _radioOnChanged,
                    ),
                    const SizedBox(width: 10),
                    const Text('Верхняя'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Radio(
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: 6,
                      groupValue: _reflectiveWall,
                      onChanged: _radioOnChanged,
                    ),
                    const SizedBox(width: 10),
                    const Text('Передняя'),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Выбрать зеркальное отражение у объекта:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _sphereReflective,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sphereReflective = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Сфера')
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _cubeReflective,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _cubeReflective = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Куб')
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Выбрать прозрачность у объекта:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _sphereTransparent,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sphereTransparent = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Сфера')
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _cubeTransparent,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _cubeTransparent = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Куб'),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    context.read<MainCubit>().render(
                        '$_reflectiveWall'
                        '${_sphereReflective ? 1 : 0}'
                        '${_cubeReflective ? 1 : 0}'
                        '${_sphereTransparent ? 1 : 0}'
                        '${_cubeTransparent ? 1 : 0}'
                        '${_softShadows ? 1 : 0}');
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Text(
                        'Применить',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

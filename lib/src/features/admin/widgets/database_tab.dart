import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../utils/styles.dart';

class DatabaseTab extends StatefulWidget {
  final String collectionName;
  const DatabaseTab({super.key, required this.collectionName});

  @override
  State<DatabaseTab> createState() => _DatabaseTabState();
}

class _DatabaseTabState extends State<DatabaseTab> {
  static const int _pageSize = 50;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';
  bool showGraph = false;
  String _sortBy = 'id'; // Default sort by ID
  bool _isAscending = true;
  bool _isLoadingList = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _loadError;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;

  @override
  void initState() {
    super.initState();
    _loadInitialDocs();
  }

  Query<Map<String, dynamic>> get _baseQuery => _firestore
      .collection(widget.collectionName)
      .orderBy(FieldPath.documentId);

  Future<void> _loadInitialDocs() async {
    setState(() {
      _isLoadingList = true;
      _isLoadingMore = false;
      _loadError = null;
      _docs = [];
      _lastDocument = null;
      _hasMore = true;
    });

    try {
      final snapshot = await _baseQuery.limit(_pageSize + 1).get();
      final pageDocs = snapshot.docs.take(_pageSize).toList();
      setState(() {
        _docs = pageDocs;
        _lastDocument = pageDocs.isNotEmpty ? pageDocs.last : null;
        _hasMore = snapshot.docs.length > _pageSize;
      });
    } catch (e) {
      setState(() => _loadError = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoadingList = false);
      }
    }
  }

  Future<void> _loadMoreDocs() async {
    if (_isLoadingList ||
        _isLoadingMore ||
        !_hasMore ||
        _lastDocument == null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _loadError = null;
    });

    try {
      final snapshot = await _baseQuery
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize + 1)
          .get();
      final pageDocs = snapshot.docs.take(_pageSize).toList();
      setState(() {
        _docs = [..._docs, ...pageDocs];
        _lastDocument = pageDocs.isNotEmpty ? pageDocs.last : _lastDocument;
        _hasMore = snapshot.docs.length > _pageSize;
      });
    } catch (e) {
      setState(() => _loadError = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          if (showGraph) _buildStatsGraph(),
          _buildSearchBar(isDark),
          _buildSortRow(isDark),
          const SizedBox(height: 8),
          Expanded(child: _buildCollectionList(isDark)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDoc,
        mini: true,
        backgroundColor: AppStyles.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search in ${widget.collectionName.split('/').last}...',
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(),
              ),
              onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
            ),
          ),
          IconButton(
            icon: Icon(showGraph ? Icons.auto_graph_rounded : Icons.insert_chart_outlined_rounded, 
              color: AppStyles.primaryColor, size: 20),
            onPressed: () => setState(() => showGraph = !showGraph),
          ),
        ],
      ),
    );
  }

  Widget _buildSortRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          const Icon(Icons.sort_rounded, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          const Text('SORT BY:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, size: 16),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            onChanged: (String? newValue) {
              if (newValue != null) setState(() => _sortBy = newValue);
            },
            items: <String>['id', 'name', 'title', 'price', 'createdAt', 'timestamp']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => setState(() => _isAscending = !_isAscending),
            icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 12),
            label: Text(_isAscending ? 'ASC' : 'DESC', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: AppStyles.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionList(bool isDark) {
    if (_isLoadingList && _docs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null && _docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Error: $_loadError',
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadInitialDocs,
              child: const Text('RETRY'),
            ),
          ],
        ),
      );
    }

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
        _docs.where((doc) {
      if (searchQuery.isEmpty) return true;
      final data = doc.data();
      final bool idMatch = doc.id.toLowerCase().contains(searchQuery);
      final bool dataMatch = data.values
          .any((v) => v.toString().toLowerCase().contains(searchQuery));
      return idMatch || dataMatch;
    }).toList();

    docs.sort((a, b) {
      dynamic valA, valB;
      final dataA = a.data();
      final dataB = b.data();

      if (_sortBy == 'id') {
        valA = a.id;
        valB = b.id;
      } else {
        valA = dataA[_sortBy] ?? '';
        valB = dataB[_sortBy] ?? '';
      }

      int cmp;
      if (valA is Comparable && valB is Comparable) {
        cmp = valA.compareTo(valB);
      } else {
        cmp = valA.toString().compareTo(valB.toString());
      }
      return _isAscending ? cmp : -cmp;
    });

    if (docs.isEmpty && searchQuery.isNotEmpty) {
      return const Center(
          child: Text('No matching records found',
              style: TextStyle(fontSize: 12, color: Colors.grey)));
    }
    if (docs.isEmpty) {
      return const Center(
          child: Text('No records found',
              style: TextStyle(fontSize: 12, color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: _loadInitialDocs,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: docs.length + 1,
        itemBuilder: (context, index) {
          if (index == docs.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: _hasMore
                    ? TextButton(
                        onPressed: _isLoadingMore ? null : _loadMoreDocs,
                        child: _isLoadingMore
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppStyles.primaryColor,
                                ),
                              )
                            : Text(
                                'LOAD MORE (${_docs.length} loaded)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppStyles.primaryColor,
                                ),
                              ),
                      )
                    : Text(
                        'END OF RESULTS (${_docs.length} loaded)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
              ),
            );
          }

          final doc = docs[index];
          final data = doc.data();

          final String preview = data.entries
              .where((e) =>
                  e.key != 'uid' &&
                  e.key != 'id' &&
                  e.key != 'createdAt' &&
                  e.value is! Map &&
                  e.value is! List)
              .take(3)
              .map((e) => '${e.key}: ${e.value}')
              .join(' | ');

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text(
                  (data['name'] ??
                          data['title'] ??
                          data['userName'] ??
                          'Record ${index + 1}')
                      .toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: preview.isNotEmpty
                  ? Text(preview,
                      style:
                          const TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)
                  : null,
              childrenPadding: const EdgeInsets.all(12),
              children: [
                SelectableText('ID: ${doc.id.toString()}',
                    style: const TextStyle(
                        fontSize: 9,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width - 64),
                    child: _buildDataGrid(data),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                        onPressed: () => _editDoc(doc),
                        icon: const Icon(Icons.edit_note, size: 18),
                        label:
                            const Text('EDIT', style: TextStyle(fontSize: 11))),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteDoc(doc),
                      icon: const Icon(Icons.delete_forever,
                          size: 18, color: Colors.red),
                      label: const Text('DELETE',
                          style: TextStyle(color: Colors.red, fontSize: 11)),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataGrid(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((e) {
        String displayValue;
        if (e.value is Map || e.value is List) {
          try {
            displayValue = const JsonEncoder.withIndent('  ').convert(e.value);
          } catch (_) {
            displayValue = e.value.toString();
          }
        } else if (e.value is Timestamp) {
          displayValue = (e.value as Timestamp).toDate().toString();
        } else {
          displayValue = e.value.toString();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 120, child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey))),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(displayValue, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsGraph() {
    return Container(
      height: 120,
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppStyles.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppStyles.primaryColor.withOpacity(0.1)),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(widget.collectionName).limit(100).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
          
          final docs = snapshot.data!.docs;
          final Map<String, int> dailyCounts = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            DateTime? date;
            if (data['createdAt'] is Timestamp) {
              date = (data['createdAt'] as Timestamp).toDate();
            } else if (data['timestamp'] is Timestamp) date = (data['timestamp'] as Timestamp).toDate();
            
            if (date != null) {
              final String key = '${date.day}/${date.month}';
              dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
            }
          }

          final sortedKeys = dailyCounts.keys.toList();
          if (sortedKeys.length > 7) sortedKeys.removeRange(0, sortedKeys.length - 7);

          if (sortedKeys.isEmpty) return const Center(child: Text('No stats available', style: TextStyle(fontSize: 10, color: Colors.grey)));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.collectionName.split('/').last.toUpperCase()} RECENT ACTIVITY', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppStyles.primaryColor)),
              const SizedBox(height: 8),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: dailyCounts.values.isEmpty ? 1 : dailyCounts.values.fold(0, (max, v) => v > max ? v : max).toDouble() + 1,
                    barGroups: sortedKeys.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: dailyCounts[e.value]!.toDouble(), color: AppStyles.primaryColor, width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(2)))] )).toList(),
                    titlesData: FlTitlesData(leftTitles: const AxisTitles(), topTitles: const AxisTitles(), rightTitles: const AxisTitles(), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text(value.toInt() < sortedKeys.length ? sortedKeys[value.toInt()] : '', style: const TextStyle(fontSize: 7))))),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final controllers = <String, TextEditingController>{};
    data.forEach((key, value) {
      if (value is Timestamp || value is GeoPoint) return;
      if (value is Map || value is List) {
        controllers[key] = TextEditingController(text: jsonEncode(value));
      } else {
        controllers[key] = TextEditingController(text: value.toString());
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('EDIT ${widget.collectionName.split('/').last.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 15),
              ...controllers.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextField(
                  controller: e.value,
                  maxLines: (data[e.key] is Map || data[e.key] is List) ? 5 : 1,
                  decoration: InputDecoration(
                    labelText: e.key, 
                    border: const OutlineInputBorder(), 
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
                    labelStyle: const TextStyle(fontSize: 12),
                    helperText: (data[e.key] is Map || data[e.key] is List) ? 'Edit as JSON string' : null,
                  ),
                ),
              )),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => _confirmSave(doc, controllers),
                  child: const Text('SAVE CHANGES', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSave(DocumentSnapshot doc, Map<String, TextEditingController> controllers) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('CONFIRM UPDATE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to update this record? This cannot be undone.', style: TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final Map<String, dynamic> updatedData = {};
              controllers.forEach((key, controller) {
                final val = controller.text;
                if (val.toLowerCase() == 'true') {
                  updatedData[key] = true;
                } else if (val.toLowerCase() == 'false') {
                  updatedData[key] = false;
                } else if (val.startsWith('{') || val.startsWith('[')) {
                  try { updatedData[key] = jsonDecode(val); } catch (_) { updatedData[key] = val; }
                } else if (num.tryParse(val) != null) {
                  updatedData[key] = num.parse(val);
                } else {
                  updatedData[key] = val;
                }
              });
              await doc.reference.update(updatedData);
              if (mounted) {
                Navigator.pop(c);
                Navigator.pop(context);
                _loadInitialDocs();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record updated successfully')));
              }
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  void _addNewDoc() {
    final keyCtrl = TextEditingController(), valCtrl = TextEditingController();
    final Map<String, dynamic> newData = {};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        title: Text('NEW ${widget.collectionName.split('/').last.toUpperCase()} RECORD', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (newData.isNotEmpty) ...[
              Wrap(children: newData.keys.map((k) => Chip(label: Text('$k: ${newData[k]}', style: const TextStyle(fontSize: 9)), onDeleted: () => setDialogState(() => newData.remove(k)))).toList()),
              const Divider(),
            ],
            TextField(controller: keyCtrl, decoration: const InputDecoration(hintText: 'Key', labelStyle: TextStyle(fontSize: 12))),
            TextField(controller: valCtrl, decoration: const InputDecoration(hintText: 'Value', labelStyle: TextStyle(fontSize: 12))),
            const SizedBox(height: 10),
            TextButton.icon(onPressed: () {
              if (keyCtrl.text.isNotEmpty) {
                setDialogState(() {
                  final val = valCtrl.text;
                  if (val.toLowerCase() == 'true') {
                    newData[keyCtrl.text] = true;
                  } else if (val.toLowerCase() == 'false') newData[keyCtrl.text] = false;
                  else if (num.tryParse(val) != null) newData[keyCtrl.text] = num.parse(val);
                  else newData[keyCtrl.text] = val;
                  keyCtrl.clear(); valCtrl.clear();
                });
              }
            }, icon: const Icon(Icons.add, size: 16), label: const Text('ADD FIELD', style: TextStyle(fontSize: 11))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(fontSize: 11))),
          ElevatedButton(onPressed: newData.isEmpty ? null : () async {
            await FirebaseFirestore.instance.collection(widget.collectionName).add({...newData, 'createdAt': FieldValue.serverTimestamp()});
            if (mounted) {
              Navigator.pop(context);
              _loadInitialDocs();
            }
          }, child: const Text('CREATE', style: TextStyle(fontSize: 11))),
        ],
      )),
    );
  }

  void _deleteDoc(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CONFIRM DELETE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Text('Delete record from ${widget.collectionName.split('/').last}?\nID: ${doc.id}', style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(fontSize: 11))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async {
            await doc.reference.delete();
            if (mounted) {
              Navigator.pop(context);
              _loadInitialDocs();
            }
          }, child: const Text('DELETE', style: TextStyle(color: Colors.white, fontSize: 11))),
        ],
      ),
    );
  }
}

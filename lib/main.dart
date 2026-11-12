
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const FriendsApp()); }
const navy=Color(0xFF101B30), gold=Color(0xFFD3AE60), surface=Color(0xFFF4F6FA);
String cash(num n)=>'Rs. ${n.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'),(m)=>',')}';

class Store extends ChangeNotifier {
  List<Map<String,dynamic>> products=[],customers=[],suppliers=[],sales=[],purchases=[],expenses=[];
  Future<void> load() async {
    final p=await SharedPreferences.getInstance();
    try {
      final d=jsonDecode(p.getString('fc_flutter_data')??'{}') as Map<String,dynamic>;
      List<Map<String,dynamic>> rows(String k)=>((d[k]??[]) as List).map((e)=>Map<String,dynamic>.from(e as Map)).toList();
      products=rows('products'); customers=rows('customers'); suppliers=rows('suppliers');
      sales=rows('sales'); purchases=rows('purchases'); expenses=rows('expenses');
    } catch (_) {}
    notifyListeners();
  }
  Future<void> persist() async {
    final p=await SharedPreferences.getInstance();
    await p.setString('fc_flutter_data',jsonEncode({'products':products,'customers':customers,'suppliers':suppliers,'sales':sales,'purchases':purchases,'expenses':expenses}));
    notifyListeners();
  }
  num get stock=>products.fold<num>(0,(s,x)=>s+(x['qty'] as num));
  num get salesTotal=>sales.fold<num>(0,(s,x)=>s+(x['total'] as num));
  num get purchasesTotal=>purchases.fold<num>(0,(s,x)=>s+(x['total'] as num));
  num get expenseTotal=>expenses.fold<num>(0,(s,x)=>s+(x['amount'] as num));
}

class FriendsApp extends StatefulWidget { const FriendsApp({super.key}); @override State<FriendsApp> createState()=>_FriendsAppState(); }
class _FriendsAppState extends State<FriendsApp> {
  final store=Store(); bool dark=false;
  @override void initState(){super.initState();store.load();}
  @override Widget build(BuildContext context)=>MaterialApp(
    title:'FRIENDS & CO.',debugShowCheckedModeBanner:false,
    theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:surface,colorScheme:ColorScheme.fromSeed(seedColor:navy,primary:navy),fontFamily:'Roboto',appBarTheme:const AppBarTheme(backgroundColor:surface)),
    darkTheme:ThemeData(useMaterial3:true,brightness:Brightness.dark,colorScheme:ColorScheme.fromSeed(seedColor:gold,brightness:Brightness.dark)),
    themeMode:dark?ThemeMode.dark:ThemeMode.light,
    home:AnimatedBuilder(animation:store,builder:(context,_)=>Home(store:store,onTheme:()=>setState(()=>dark=!dark))),
  );
}

class Home extends StatefulWidget { final Store store; final VoidCallback onTheme; const Home({super.key,required this.store,required this.onTheme}); @override State<Home> createState()=>_HomeState(); }
class _HomeState extends State<Home> {
 int tab=0; final names=['Dashboard','Sales','Purchase','Stock','More'];
 void jump(int t)=>setState(()=>tab=t);
 @override Widget build(BuildContext context){
   final s=widget.store;
   return Scaffold(
     appBar:AppBar(toolbarHeight:74,titleSpacing:18,title:Row(children:[
       Container(width:44,height:44,decoration:BoxDecoration(color:navy,borderRadius:BorderRadius.circular(13)),alignment:Alignment.center,child:const Text('F&C',style:TextStyle(color:gold,fontWeight:FontWeight.w800,fontSize:14))),
       const SizedBox(width:11),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
         Text('FRIENDS & CO.',style:TextStyle(fontWeight:FontWeight.w800,fontSize:16,letterSpacing:.4)),
         Text('Wholesale Manager',style:TextStyle(fontSize:11,color:Colors.grey)),
       ])),
     ]),actions:[IconButton(tooltip:'Toggle theme',onPressed:widget.onTheme,icon:const Icon(Icons.dark_mode_outlined)),const SizedBox(width:5)]),
     body:SafeArea(child:IndexedStack(index:tab,children:[
       dashboard(s),records('Sales',s.sales,()=>form(context,s,'sale')),
       records('Purchase',s.purchases,()=>form(context,s,'purchase')),
       stock(s),more(s),
     ])),
     bottomNavigationBar:NavigationBar(height:72,selectedIndex:tab,onDestinationSelected:jump,
       destinations:const [
         NavigationDestination(icon:Icon(Icons.grid_view_outlined),selectedIcon:Icon(Icons.grid_view),label:'Home'),
         NavigationDestination(icon:Icon(Icons.receipt_long_outlined),label:'Sales'),
         NavigationDestination(icon:Icon(Icons.shopping_bag_outlined),label:'Purchase'),
         NavigationDestination(icon:Icon(Icons.inventory_2_outlined),label:'Stock'),
         NavigationDestination(icon:Icon(Icons.menu_rounded),label:'More'),
       ]),
   );
 }
 Widget dashboard(Store s)=>ListView(padding:const EdgeInsets.fromLTRB(16,12,16,24),children:[
   Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:navy,borderRadius:BorderRadius.circular(20)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Text("TODAY'S NET PROFIT",style:TextStyle(color:gold,fontWeight:FontWeight.w700,fontSize:12,letterSpacing:1)),
     SizedBox(height:12),Text('Not calculated yet',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w700,fontSize:22)),
     SizedBox(height:6),Text('Profit accounting is not implemented in this test build',style:TextStyle(color:Colors.white70,fontSize:11)),
   ])),
   const SizedBox(height:18),
   GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,childAspectRatio:1.75,crossAxisSpacing:10,mainAxisSpacing:10,children:[
     metric('Sales (all dates)',cash(s.salesTotal),Icons.trending_up),
     metric('Purchase (all dates)',cash(s.purchasesTotal),Icons.shopping_bag_outlined),
     metric('Expenses (all dates)',cash(s.expenseTotal),Icons.payments_outlined),
     metric('Stock', '${s.stock} Outers',Icons.inventory_2_outlined),
   ]),
   const SizedBox(height:23),const Text('Quick Actions',style:TextStyle(fontWeight:FontWeight.w800,fontSize:17)),const SizedBox(height:12),
   GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:3,childAspectRatio:1.14,crossAxisSpacing:10,mainAxisSpacing:10,children:[
     action('New Sale',Icons.add_shopping_cart,()=>form(context,s,'sale')),
     action('Purchase',Icons.shopping_cart_checkout,()=>form(context,s,'purchase')),
     action('Product',Icons.add_box_outlined,()=>form(context,s,'product')),
     action('Customer',Icons.person_add_alt,()=>form(context,s,'customer')),
     action('Supplier',Icons.local_shipping_outlined,()=>form(context,s,'supplier')),
     action('Expense',Icons.receipt_long,()=>form(context,s,'expense')),
   ]),
   const SizedBox(height:20),info('Godown-wise stock and customer outstanding will appear after those modules are implemented.'),
 ]);
 Widget metric(String label,String value,IconData icon)=>Card(elevation:0,child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
   Icon(icon,color:gold,size:20),Text(label,style:const TextStyle(fontSize:11,color:Colors.grey)),Text(value,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800)),
 ])));
 Widget action(String title,IconData icon,VoidCallback tap)=>Material(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(14),child:InkWell(borderRadius:BorderRadius.circular(14),onTap:tap,child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
   Icon(icon,color:gold,size:26),const SizedBox(height:9),Text(title,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700)),
 ])));
 Widget info(String message)=>Card(elevation:0,child:Padding(padding:const EdgeInsets.all(18),child:Row(children:[const Icon(Icons.info_outline,color:Colors.grey),const SizedBox(width:10),Expanded(child:Text(message,style:const TextStyle(fontSize:12,color:Colors.grey)))])));
 Widget records(String title,List<Map<String,dynamic>> items,VoidCallback add)=>ListView(padding:const EdgeInsets.all(16),children:[
   heading(title,add),if(items.isEmpty)empty('No ${title.toLowerCase()} records yet'),
   for(final x in items)Card(elevation:0,child:ListTile(title:Text(x['no']??'',style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('${x['party']} · ${x['product']} · ${x['qty']} Outers'),trailing:Text(cash(x['total'] as num),style:const TextStyle(fontWeight:FontWeight.w700)))),
 ]);
 Widget heading(String title,VoidCallback add)=>Padding(padding:const EdgeInsets.only(bottom:15),child:Row(children:[Expanded(child:Text(title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:21))),FilledButton.icon(onPressed:add,icon:const Icon(Icons.add,size:17),label:const Text('Add'))]));
 Widget empty(String title)=>Padding(padding:const EdgeInsets.symmetric(vertical:70),child:Center(child:Column(children:[const Icon(Icons.inbox_outlined,size:42,color:Colors.grey),const SizedBox(height:12),Text(title,style:const TextStyle(color:Colors.grey))])));
 Widget stock(Store s)=>ListView(padding:const EdgeInsets.all(16),children:[
   heading('Products',()=>form(context,s,'product')),if(s.products.isEmpty)empty('No products yet'),
   for(final p in s.products)Card(elevation:0,child:ListTile(leading:const CircleAvatar(child:Icon(Icons.inventory_2_outlined)),title:Text(p['name']),subtitle:const Text('Current quantity'),trailing:Text('${p['qty']} Outers',style:const TextStyle(fontWeight:FontWeight.w700)))),
 ]);
 Widget more(Store s)=>ListView(padding:const EdgeInsets.all(16),children:[
   for(final entry in [('Customers','customer',s.customers),('Suppliers','supplier',s.suppliers),('Expenses','expense',s.expenses)])
     Card(elevation:0,margin:const EdgeInsets.only(bottom:12),child:ExpansionTile(title:Text(entry.$1 as String,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('${(entry.$3 as List).length} records'),trailing:IconButton(icon:const Icon(Icons.add_circle_outline),onPressed:()=>form(context,s,entry.$2 as String)),children:[
       for(final x in entry.$3 as List<Map<String,dynamic>>)ListTile(title:Text('${x['name']??x['category']}'),subtitle:Text(x['phone']??''),trailing:Text(x['amount']==null?'':cash(x['amount'] as num))),
     ])),
   const SizedBox(height:8),info('Test app: local storage only. No cloud backup, ledger, multi-godown, PDF invoices or authentication yet.'),
 ]);
}

Future<void> form(BuildContext context,Store s,String type) async {
 final name=TextEditingController(),phone=TextEditingController(),qty=TextEditingController(text:type=='product'?'0':''),rate=TextEditingController(),amount=TextEditingController();
 String? party,product; final key=GlobalKey<FormState>();
 final title={'product':'Add Product','customer':'Add Customer','supplier':'Add Supplier','expense':'Add Expense','sale':'New Sale','purchase':'New Purchase'}[type]!;
 final parties=type=='sale'?s.customers:s.suppliers;
 await showModalBottomSheet<void>(context:context,isScrollControlled:true,showDragHandle:true,useSafeArea:true,builder:(ctx)=>StatefulBuilder(builder:(ctx,setModal)=>Padding(
   padding:EdgeInsets.fromLTRB(20,0,20,MediaQuery.of(ctx).viewInsets.bottom+20),child:SingleChildScrollView(child:Form(key:key,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,mainAxisSize:MainAxisSize.min,children:[
     Text(title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:22)),const SizedBox(height:16),
     if(['product','customer','supplier'].contains(type))field('Name',name),
     if(['customer','supplier'].contains(type))field('Phone (optional)',phone,number:true),
     if(type=='product')field('Opening stock (whole Outers)',qty,number:true),
     if(type=='expense')... [field('Expense category',name),field('Amount (PKR)',amount,number:true)],
     if(['sale','purchase'].contains(type))...[
       DropdownButtonFormField<String>(value:party,decoration:const InputDecoration(labelText:'Customer / Supplier',border:OutlineInputBorder()),items:parties.map((p)=>DropdownMenuItem<String>(value:p['name'] as String,child:Text(p['name']))).toList(),onChanged:(v)=>setModal(()=>party=v)),
       const SizedBox(height:12),
       DropdownButtonFormField<String>(value:product,decoration:const InputDecoration(labelText:'Product',border:OutlineInputBorder()),items:s.products.map((p)=>DropdownMenuItem<String>(value:p['name'] as String,child:Text(p['name']))).toList(),onChanged:(v)=>setModal(()=>product=v)),
       const SizedBox(height:12),field('Quantity (whole Outers)',qty,number:true),field('Rate per Outer (PKR)',rate,number:true),
       const Text('One product per invoice in this test version.',style:TextStyle(fontSize:12,color:Colors.grey)),
     ],
     const SizedBox(height:20),
     FilledButton(onPressed:()async{
       final n=name.text.trim();final q=int.tryParse(qty.text.trim());final r=double.tryParse(rate.text.trim());final a=double.tryParse(amount.text.trim());
       if(['product','customer','supplier','expense'].contains(type)&&n.isEmpty){ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content:Text('Name / category is required')));return;}
       if(type=='product'&&(q==null||q<0)){ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content:Text('Enter valid whole Outers')));return;}
       if(type=='expense'&&(a==null||a<=0)){ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content:Text('Enter valid amount')));return;}
       if(['sale','purchase'].contains(type)&&(party==null||product==null||q==null||q<=0||r==null||r<=0)){ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content:Text('Select party, product and enter valid quantity/rate')));return;}
       if(type=='product')s.products.add({'name':n,'qty':q!});
       if(type=='customer')s.customers.add({'name':n,'phone':phone.text.trim()});
       if(type=='supplier')s.suppliers.add({'name':n,'phone':phone.text.trim()});
       if(type=='expense')s.expenses.add({'category':n,'amount':a!,'date':DateTime.now().toIso8601String()});
       if(type=='sale'||type=='purchase'){
         final p=s.products.firstWhere((e)=>e['name']==product);
         final available=(p['qty'] as num).toInt();
         if(type=='sale'&&q!>available){
           final proceed=await showDialog<bool>(context:ctx,builder:(d)=>AlertDialog(title:const Text('Insufficient stock'),content:Text('Available: $available Outers. Continue with negative stock?'),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(d,true),child:const Text('Continue'))]));
           if(proceed!=true)return;
         }
         p['qty']=available+(type=='sale'?-q!:q!);
         final rows=type=='sale'?s.sales:s.purchases;
         rows.add({'no':'${type=='sale'?'SALE':'PUR'}-${(rows.length+1).toString().padLeft(4,'0')}','party':party,'product':product,'qty':q,'rate':r,'total':q!*r!,'date':DateTime.now().toIso8601String()});
       }
       await s.persist();
       if(ctx.mounted)Navigator.pop(ctx);
     },child:const Padding(padding:EdgeInsets.all(13),child:Text('Save Record'))),
   ]))))));
}
Widget field(String title,TextEditingController c,{bool number=false})=>Padding(padding:const EdgeInsets.only(bottom:12),child:TextFormField(controller:c,keyboardType:number?const TextInputType.numberWithOptions(decimal:true):TextInputType.text,decoration:InputDecoration(labelText:title,border:const OutlineInputBorder(),contentPadding:const EdgeInsets.symmetric(horizontal:13,vertical:15))));

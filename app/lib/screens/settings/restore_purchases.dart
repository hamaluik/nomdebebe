import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/blocs/iap/iap_bloc.dart';

class RestorePurchases extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(FontAwesomeIcons.searchDollar),
      title: Text("Restore Purchases"),
      trailing: Icon(FontAwesomeIcons.chevronRight),
      onTap: () => BlocProvider.of<IAPBloc>(context).add(IAPRestorePurchases()),
    );
  }
}

library m4d_content_sample.actions;

import 'package:m4d_flux/m4d_flux.dart';

// - Actions sent by our app -------------------------------------------------------------------------------------------

class ListChangedAction extends Action {
    static const ActionName NAME = const ActionName("m4d_content_sample.actions.ListChangedAction");
    const ListChangedAction() : super(ActionType.Signal, NAME);
}

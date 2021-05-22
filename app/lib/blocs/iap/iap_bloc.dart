import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:nomdebebe/models/nullable.dart';

class IAPEvent extends Equatable {
  const IAPEvent();
  @override
  List<Object?> get props => [];
}

class IAPLoadProducts extends IAPEvent {
  const IAPLoadProducts();
}

class IAPRestorePurchases extends IAPEvent {
  const IAPRestorePurchases();
}

class IAPPurchaseUpgradeSharing extends IAPEvent {
  const IAPPurchaseUpgradeSharing();
}

class _IAPUpgradeSharingIsPending extends IAPEvent {
  const _IAPUpgradeSharingIsPending();
}

class _IAPUpgradeSharingIsPurchased extends IAPEvent {
  const _IAPUpgradeSharingIsPurchased();
}

class _IAPUpgradeSharingIsError extends IAPEvent {
  final IAPError? error;
  const _IAPUpgradeSharingIsError(this.error);
  @override
  List<Object?> get props => [error];
}

class IAPState extends Equatable {
  final List<ProductDetails> productDetails;
  final bool hasUpgradedSharing;
  final bool upgradedSharingIsPending;
  final IAPError? upgradedSharingError;

  IAPState.initial()
      : productDetails = List.empty(),
        hasUpgradedSharing = false,
        upgradedSharingIsPending = false,
        upgradedSharingError = null;

  IAPState(this.productDetails, this.hasUpgradedSharing,
      this.upgradedSharingIsPending, this.upgradedSharingError);

  IAPState copyWith({
    List<ProductDetails>? productDetails,
    bool? hasUpgradedSharing,
    bool? upgradedSharingIsPending,
    Nullable<IAPError?>? upgradedSharingError,
  }) =>
      IAPState(
        productDetails ?? this.productDetails,
        hasUpgradedSharing ?? this.hasUpgradedSharing,
        upgradedSharingIsPending ?? this.upgradedSharingIsPending,
        upgradedSharingError == null
            ? this.upgradedSharingError
            : upgradedSharingError.value,
      );
  @override
  List<Object?> get props => [
        productDetails,
        hasUpgradedSharing,
        upgradedSharingIsPending,
        upgradedSharingError
      ];
}

class IAPBloc extends Bloc<IAPEvent, IAPState> {
  static const Set<String> _kIds = <String>{'upgrade.sharing'};
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  IAPBloc() : super(IAPState.initial());

  void init() {
    _subscription = InAppPurchase.instance.purchaseStream
        .listen((List<PurchaseDetails> purchaseDetailsList) {
      purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
        switch (purchaseDetails.productID) {
          case 'upgrade.sharing':
            {
              switch (purchaseDetails.status) {
                case PurchaseStatus.pending:
                  add(_IAPUpgradeSharingIsPending());
                  break;
                case PurchaseStatus.error:
                  add(_IAPUpgradeSharingIsError(purchaseDetails.error));
                  break;
                case PurchaseStatus.purchased:
                case PurchaseStatus.restored:
                  add(_IAPUpgradeSharingIsPurchased());
                  break;
              }

              if (purchaseDetails.pendingCompletePurchase) {
                await InAppPurchase.instance.completePurchase(purchaseDetails);
              }
            }
            break;
          default:
            print(
                "Unknown purchase product: ${purchaseDetails.productID} => ${purchaseDetails.status}");
        }
      });
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  @override
  Stream<IAPState> mapEventToState(IAPEvent event) async* {
    if (event is IAPLoadProducts) {
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(_kIds);
      if (response.error != null)
        print("Failed to query error: ${response.error}");
      if (response.notFoundIDs.isNotEmpty)
        print("Failed to find details for products: " +
            response.notFoundIDs.join(", "));
      yield state.copyWith(productDetails: response.productDetails);
    } else if (event is IAPRestorePurchases) {
      await InAppPurchase.instance.restorePurchases();
      yield state.copyWith();
    } else if (event is IAPPurchaseUpgradeSharing) {
      ProductDetails? productDetails;
      try {
        productDetails = state.productDetails.firstWhere(
            (ProductDetails details) => details.id == 'upgrade.sharing');
      } catch (_) {}
      if (productDetails != null) {
        await InAppPurchase.instance.buyNonConsumable(
            purchaseParam: PurchaseParam(productDetails: productDetails));
        yield state.copyWith();
      }
    } else if (event is _IAPUpgradeSharingIsPending) {
      yield state.copyWith(
          upgradedSharingError: Nullable(null),
          hasUpgradedSharing: false,
          upgradedSharingIsPending: true);
    } else if (event is _IAPUpgradeSharingIsError) {
      yield state.copyWith(
          upgradedSharingError: Nullable(event.error),
          hasUpgradedSharing: false,
          upgradedSharingIsPending: false);
    } else if (event is _IAPUpgradeSharingIsPurchased) {
      yield state.copyWith(
          upgradedSharingError: Nullable(null),
          hasUpgradedSharing: true,
          upgradedSharingIsPending: false);
    }
  }
}

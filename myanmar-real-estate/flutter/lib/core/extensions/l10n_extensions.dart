import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../../l10n/gen/app_localizations.dart';

extension HouseTypeL10n on String {
  String localizedName(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (this) {
      case HouseTypes.apartment:  return l.typeApartment;
      case HouseTypes.house:      return l.typeHouse;
      case HouseTypes.townhouse:  return l.typeTownhouse;
      case HouseTypes.land:       return l.typeLand;
      case HouseTypes.commercial: return l.typeCommercial;
      default:                    return this;
    }
  }
}

extension TransactionTypeL10n on String {
  String localizedTransactionName(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (this) {
      case TransactionTypes.sale: return l.transactionSale;
      case TransactionTypes.rent: return l.transactionRent;
      default:                    return this;
    }
  }
}

extension DecorationTypeL10n on String {
  String localizedDecorationName(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (this) {
      case DecorationTypes.rough:   return l.decorationRough;
      case DecorationTypes.simple:  return l.decorationSimple;
      case DecorationTypes.fine:    return l.decorationFine;
      case DecorationTypes.luxury:  return l.decorationLuxury;
      default:                      return this;
    }
  }
}

extension HouseStatusL10n on String {
  String localizedStatusName(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (this) {
      case HouseStatus.pending:   return l.statusPending;
      case HouseStatus.verifying: return l.statusVerifying;
      case HouseStatus.online:    return l.statusOnline;
      case HouseStatus.offline:   return l.statusOffline;
      case HouseStatus.sold:      return l.statusSold;
      case HouseStatus.rejected:  return l.statusRejected;
      default:                    return this;
    }
  }
}

extension AppointmentStatusL10n on String {
  String localizedAppointmentStatus(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (this) {
      case AppointmentStatus.pending:   return l.appointmentPending;
      case AppointmentStatus.confirmed: return l.appointmentConfirmed;
      case AppointmentStatus.rejected:  return l.appointmentRejected;
      case AppointmentStatus.cancelled: return l.appointmentCancelled;
      case AppointmentStatus.completed: return l.appointmentCompleted;
      case AppointmentStatus.noShow:    return l.appointmentNoShow;
      default:                          return this;
    }
  }
}

extension AcnRoleL10n on String {
  String localizedRoleName(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (this) {
      case AcnRoles.entrant:      return l.roleEntrant;
      case AcnRoles.maintainer:   return l.roleMaintainer;
      case AcnRoles.introducer:   return l.roleIntroducer;
      case AcnRoles.accompanier:  return l.roleAccompanier;
      case AcnRoles.closer:       return l.roleCloser;
      default:                    return this;
    }
  }
}

extension CityL10n on String {
  String localizedCityName(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (this) {
      case CityCodes.yangon:    return l.cityYangon;
      case CityCodes.mandalay:  return l.cityMandalay;
      case CityCodes.naypyitaw: return l.cityNaypyitaw;
      default:                  return this;
    }
  }
}

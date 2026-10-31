import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/account_identity/components/identity_address_section.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/account_identity/components/identity_contact_section.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/account_identity/components/identity_personal_section.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/account_identity/identity_display_extensions.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/account_identity/identity_edit_actions.dart';
import 'package:amanah_healthcare/features/home/presentation/state/account_identity_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Screen presenting the user's personal identity, contact, and administrative address.
class AmanahAccountIdentitySettingsScreen extends StatefulWidget {
  const AmanahAccountIdentitySettingsScreen({required this.user, this.onBack, super.key});

  final AmanahAuthUser user;
  final VoidCallback? onBack;

  @override
  State<AmanahAccountIdentitySettingsScreen> createState() =>
      _AmanahAccountIdentitySettingsScreenState();
}

class _AmanahAccountIdentitySettingsScreenState extends State<AmanahAccountIdentitySettingsScreen>
    with IdentityEditActions {
  late final AccountIdentityController _controller;

  @override
  AccountIdentityController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _controller = AccountIdentityController(user: widget.user);
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AmanahThemeTokens.canvas(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(
              title: widget.user.roleName.isNotEmpty
                  ? 'Akun & Identitas ${widget.user.roleName}'
                  : 'Akun & Identitas',
              onBack: widget.onBack,
            ),
            ListenableBuilder(
              listenable: _controller,
              builder: (BuildContext ctx, Widget? child) {
                if (_controller.isLoading || _controller.isSaving) {
                  return const LinearProgressIndicator(
                    minHeight: 2,
                    color: AmanahColorTokens.brand,
                  );
                }
                return const SizedBox(height: 2);
              },
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (BuildContext ctx, Widget? child) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      IdentitySettingsConstants.bottomPadding +
                          MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        IdentityPersonalSection(
                          controller: _controller,
                          onEditName: editName,
                          onEditNik: editNik,
                          onEditBirthPlace: editBirthPlace,
                          onEditBirthDate: editBirthDate,
                          onEditGender: editGender,
                        ),
                        const SizedBox(height: 20),
                        IdentityContactSection(
                          controller: _controller,
                          onEditPhone: editPhone,
                          onEditEmail: editEmail,
                        ),
                        const SizedBox(height: 20),
                        IdentityAddressSection(
                          controller: _controller,
                          onEditProvince: editProvince,
                          onEditRegency: editRegency,
                          onEditDistrict: editDistrict,
                          onEditVillage: editVillage,
                          onEditLine1: editLine1,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

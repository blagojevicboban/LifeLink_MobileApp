import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import '../core/localization.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isSerbian = loc.locale.languageCode == 'sr';

    return Scaffold(
      backgroundColor: const Color(0xFF020E15),
      appBar: AppBar(
        title: Text(
          loc.get('help'),
          style: GoogleFonts.rajdhani(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFF051923),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(loc.get('user_manual')),
            const SizedBox(height: 24),
            _buildSection(
              isSerbian ? "Dobrodošli" : "Welcome",
              isSerbian
                  ? "Dobrodošli u uputstvo za korišćenje vaše pametne narukvice LifeLink! Ova narukvica je vaš čuvar u sferama zdravlja i bezbednosti."
                  : "Welcome to the user guide for your LifeLink smart bracelet! This bracelet is your guardian for health and safety.",
              Icons.info_outline,
            ),
            _buildSection(
              isSerbian ? "Kako vas LifeLink štiti?" : "How LifeLink Protects You",
              isSerbian
                  ? "Putem moćnih senzora, on stalno 'sluša' vaše srce, krvotok i svaku promenu u brzini kretanja. Sprečava lažne uzbune i garantuje pomoć kada je zaista potrebna."
                  : "Through powerful sensors, it constantly 'listens' to your heart, blood flow, and every change in speed. It prevents false alarms and guarantees help when truly needed.",
              Icons.security,
            ),
            _buildSection(
              isSerbian ? "Osnovna Navigacija na satu" : "Basic Watch Navigation",
              isSerbian
                  ? "1. Glavni Ekran: Prikaz pulsa, kiseonika i statusa (GPS, GSM).\n2. Debug (Levo): Testiranje pada.\n3. Kontakti (Dole/Pored): Unos broja za hitne slučajeve."
                  : "1. Main Screen: Heart rate, SpO2, and status (GPS, GSM).\n2. Debug (Left): Fall simulation.\n3. Contacts (Down/Next): Emergency number input.",
              Icons.swipe,
            ),
            _buildSection(
              isSerbian ? "Hitni Ekran (SOS)" : "Emergency Screen (SOS)",
              isSerbian
                  ? "Kada se detektuje pad, aktivira se crveni ekran sa odbrojavanjem od 15 sekundi. Ako ste dobro, prevucite prstom da otkažete. U suprotnom, šalje se poziv u pomoć."
                  : "When a fall is detected, a red screen with a 15-second countdown appears. If you're okay, swipe to cancel. Otherwise, a help request is sent.",
              Icons.warning_amber_rounded,
            ),
            _buildSection(
              isSerbian ? "Cloud Sinhronizacija" : "Cloud Sync",
              isSerbian
                  ? "Vaši podaci se automatski čuvaju u oblaku. Čak i ako niste pored telefona, sat može koristiti WiFi da pošalje informacije porodici u realnom vremenu."
                  : "Your data is automatically saved in the cloud. Even if you are not near your phone, the watch can use WiFi to send real-time information to your family.",
              Icons.cloud_sync,
            ),
            _buildSection(
              isSerbian ? "Live Mapa" : "Live Map",
              isSerbian
                  ? "Aplikacija u realnom vremenu prati lokaciju i vašeg telefona i sata. Ovo pomaže spasiocima da vas brže pronađu u hitnim slučajevima."
                  : "The app tracks the real-time location of both your phone and the watch. This helps responders find you much faster in emergencies.",
              Icons.map_outlined,
            ),
            _buildSection(
              loc.get('cloud_monitoring'),
              "${loc.get('cloud_monitoring_desc')}\n\n${loc.get('visit_dashboard')}\n${loc.get('dashboard_url')}",
              Icons.dashboard_customize_outlined,
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "LifeLink © 2024",
                style: GoogleFonts.rajdhani(
                  color: Colors.white24,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.rajdhani(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
            ),
            child: Icon(icon, color: AppTheme.accent, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.rajdhani(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
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

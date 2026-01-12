import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/font_helper.dart';
import 'login_screen_2.dart';

// Custom ScrollPhysics pour empêcher le retour à la page 0
class NoBackwardPageScrollPhysics extends PageScrollPhysics {
  final bool hasLeftFirstPage;
  
  const NoBackwardPageScrollPhysics({
    required this.hasLeftFirstPage,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  NoBackwardPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoBackwardPageScrollPhysics(
      hasLeftFirstPage: hasLeftFirstPage,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (hasLeftFirstPage) {
      // Empêcher complètement le scroll vers l'arrière (vers la page 0)
      // Bloquer si on essaie de scroller vers une position inférieure à la position minimale
      if (value < position.minScrollExtent) {
        return position.minScrollExtent - value; // Bloquer complètement le scroll
      }
      // Bloquer aussi si on essaie de scroller vers l'arrière depuis n'importe quelle position
      if (value < position.pixels) {
        return position.pixels - value; // Bloquer le scroll vers l'arrière
      }
    }
    return super.applyBoundaryConditions(position, value);
  }
}

class AccueilScreen extends StatefulWidget {
  @override
  _AccueilScreenState createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  Timer? _autoNavigateTimer;
  bool _hasLeftFirstPage = false; // Flag pour empêcher le retour à la première page

  List<Map<String, dynamic>> _getPages(LanguageProvider langProvider) {
    return [
      {
        'title': '',
        'subtitle': '',
        'image': 'assets/images/onboarding1.png',
      },
      {
        'title': langProvider.translate('onboarding1_title'),
        'subtitle': langProvider.translate('onboarding1_subtitle'),
        'image': 'assets/images/onboarding2.png',
      },
      {
        'title': langProvider.translate('onboarding2_title'),
        'subtitle': langProvider.translate('onboarding2_subtitle'),
        'image': 'assets/images/onboarding3.png',
      },
      {
        'title': langProvider.translate('onboarding3_title'),
        'subtitle': langProvider.translate('onboarding3_subtitle'),
        'image': 'assets/images/onboarding4.png',
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    // Listener pour empêcher le retour à la page 0 - très réactif
    _controller.addListener(() {
      if (_hasLeftFirstPage && _controller.hasClients) {
        final currentPage = _controller.page ?? _currentIndex.toDouble();
        // Si on essaie de revenir à la page 0 (même partiellement), bloquer immédiatement
        if (currentPage < 1.0 && _currentIndex >= 1) {
          // Bloquer immédiatement et forcer le retour à la page actuelle
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _controller.hasClients) {
              _controller.jumpToPage(_currentIndex);
            }
          });
        }
      }
    });
    
    // Délai de 5 secondes pour la première page, puis navigation automatique
    _autoNavigateTimer = Timer(Duration(seconds: 5), () {
      if (mounted && _currentIndex == 0) {
        setState(() {
          _hasLeftFirstPage = true; // Marquer qu'on a quitté la première page
        });
        _controller.jumpToPage(1); // Sauter directement à la page 2 (onboarding2)
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _autoNavigateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    final pages = _getPages(langProvider);
    
    return WillPopScope(
      onWillPop: () async {
        // Empêcher le retour en arrière si on a quitté la première page
        if (_hasLeftFirstPage) {
          return false; // Empêcher le retour
        }
        return true; // Permettre le retour seulement si on est encore sur la première page
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              // Intercepter TOUTES les tentatives de scroll vers l'arrière vers la page 0
              if (_hasLeftFirstPage) {
                if (notification is ScrollStartNotification || 
                    notification is ScrollUpdateNotification) {
                  // Vérifier si on essaie de revenir à la page 0
                  if (_controller.hasClients) {
                    final position = _controller.position;
                    final page = _controller.page ?? _currentIndex.toDouble();
                    // Bloquer si on essaie de scroller vers le début (page 0) ou si on est proche de la page 0
                    if ((position.pixels < position.minScrollExtent || page < 1.0) && _currentIndex >= 1) {
                      // Bloquer le scroll immédiatement
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _controller.hasClients) {
                          _controller.jumpToPage(_currentIndex);
                        }
                      });
                      return true; // Consommer la notification
                    }
                  }
                }
              }
              return false;
            },
            child: GestureDetector(
              // Bloquer complètement les gestes de swipe vers l'arrière
              onHorizontalDragUpdate: _hasLeftFirstPage ? (details) {
                // Si on essaie de swiper vers la droite (vers l'arrière), bloquer
                if (details.delta.dx > 0 && _currentIndex >= 1) {
                  // Bloquer le geste
                  return;
                }
              } : null,
              child: PageView.builder(
                controller: _controller,
                // Désactiver complètement le swipe manuel sur toutes les pages
                // La navigation se fera uniquement via le bouton central
                physics: NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                // Empêcher le retour à la première page une fois qu'on l'a quittée
                if (index == 0 && _hasLeftFirstPage) {
                  // Forcer immédiatement le retour à la page actuelle (sans attendre)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _controller.hasClients) {
                      _controller.jumpToPage(_currentIndex > 0 ? _currentIndex : 1);
                    }
                  });
                  return;
                }
                
                // Bloquer aussi si on essaie d'aller vers une page inférieure à la page actuelle
                if (_hasLeftFirstPage && index < _currentIndex && index < 1) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _controller.hasClients) {
                      _controller.jumpToPage(_currentIndex > 0 ? _currentIndex : 1);
                    }
                  });
                  return;
                }
                
                setState(() {
                  _currentIndex = index;
                  // Marquer qu'on a quitté la première page si on passe à la page 2 ou plus
                  if (index > 0 && !_hasLeftFirstPage) {
                    _hasLeftFirstPage = true;
                  }
                });
                // Annuler le timer si l'utilisateur navigue manuellement
                _autoNavigateTimer?.cancel();
              },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              // Toutes les pages 2, 3, 4 ont un fond bleu complet
              bool isBlueBackground = index >= 1;
              
              // Page 1 (index 0) - Logo ARS avec icônes
              if (index == 0) {
                return _buildFirstPageWithLogo(langProvider);
              }
              
              return GestureDetector(
                onTap: () {
                  // Sur la dernière page, navigation directe vers login
                  if (index == pages.length - 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen2()),
                    );
                  }
                },
                child: Container(
                  color: isBlueBackground ? Color(0xFF0059AB) : Colors.white,
                  child: Stack(
                  children: [
                    // Image de fond pour les pages onboarding2, onboarding3 et onboarding4 - occupe tout l'espace
                    if (index == 1 || index == 2 || index == 3)
                      Positioned.fill(
                        child: Image.asset(
                          pages[index]['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            Container(color: Color(0xFF0059AB)),
                        ),
                      ),
                    
                    // Gradient bleu qui se fond progressivement en bas pour les pages onboarding2, onboarding3 et onboarding4
                    if (index == 1 || index == 2 || index == 3)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 160.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF0059AB).withOpacity(0.0),
                                Color(0xFF0059AB).withOpacity(0.1),
                                Color(0xFF0059AB).withOpacity(0.3),
                                Color(0xFF0059AB).withOpacity(0.6),
                                Color(0xFF0059AB).withOpacity(0.85),
                                Color(0xFF0059AB),
                              ],
                              stops: [0.0, 0.2, 0.4, 0.65, 0.85, 1.0],
                            ),
                          ),
                        ),
                      ),
                    
                    // Contenu principal
                    SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: (index == 1 || index == 2 || index == 3) ? 20.h : 30.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Titre en haut pour pages 2, 3, 4
                                  if (isBlueBackground && pages[index]['title'] != '') ...[
                                    Text(
                                      pages[index]['title'],
                                      style: getSourceSerifProStyle(
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      pages[index]['subtitle'],
                                      style: getSourceSerifProStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 60.h),
                                  ],
                                  
                                  // Image centrée avec taille adaptative et flou progressif en bas (pour page 1 seulement)
                                  if (index == 0)
                                    Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        // Image principale (non floutée)
                                        Image.asset(
                                          pages[index]['image'],
                                          height: isBlueBackground ? 520.h : 400.h,
                                          width: isBlueBackground ? double.infinity : 350.w,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) => 
                                            Icon(Icons.restaurant, size: 300.h, color: isBlueBackground ? Colors.white : Color(0xFF0059AB)),
                                        ),
                                        // Image floutée progressivement en bas avec masque de gradient
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: ClipRect(
                                            child: ShaderMask(
                                              shaderCallback: (Rect bounds) {
                                                return LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.transparent,
                                                    Colors.white.withOpacity(0.3),
                                                    Colors.white.withOpacity(0.7),
                                                    Colors.white,
                                                  ],
                                                  stops: [0.0, 0.4, 0.6, 0.8, 1.0],
                                                ).createShader(bounds);
                                              },
                                              blendMode: BlendMode.dstIn,
                                              child: ImageFiltered(
                                                imageFilter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                                                child: Image.asset(
                                                  pages[index]['image'], // On peut garder pages[index] ici car l'image ne change pas
                                                  height: isBlueBackground ? 520.h : 400.h,
                                                  width: isBlueBackground ? double.infinity : 350.w,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) => 
                                                    Icon(Icons.restaurant, size: 300.h, color: isBlueBackground ? Colors.white : Color(0xFF0059AB)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Gradient bleu qui se fond progressivement dans le fond
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 160.h,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color(0xFF0059AB).withOpacity(0.0),
                                                  Color(0xFF0059AB).withOpacity(0.1),
                                                  Color(0xFF0059AB).withOpacity(0.3),
                                                  Color(0xFF0059AB).withOpacity(0.6),
                                                  Color(0xFF0059AB).withOpacity(0.85),
                                                  Color(0xFF0059AB),
                                                ],
                                                stops: [0.0, 0.2, 0.4, 0.65, 0.85, 1.0],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 100.h),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bande bleue en bas avec courbe (pour pages 2, 3, 4)
                    if (index > 0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipPath(
                          clipper: TopWaveClipper(),
                          child: Container(
                            width: double.infinity,
                            height: 120.h,
                            color: Color(0xFF0059AB),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Dots - Positionnés dans la bande bleue
                                Padding(
                                  padding: EdgeInsets.only(bottom: 30.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(pages.length - 1, (i) {
                                      int dotIndex = i + 1; // Les dots commencent à l'index 1 (page 2)
                                      bool isCurrentPage = index == dotIndex;
                                      
                                      return AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                                        width: isCurrentPage ? 28.w : 8.w,
                                        height: 8.h,
                                        decoration: BoxDecoration(
                                          color: isCurrentPage ? Colors.white : Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    
                    // Flèche de navigation centrée en bas (sur toutes les pages 2, 3, 4)
                    // Déplacée après la bande bleue pour être sur le dessus
                    if (index > 0)
                      Positioned(
                        bottom: 90.h,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              if (index < pages.length - 1) {
                                _controller.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                // Sur la dernière page, navigation directe vers login
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginScreen2()),
                                );
                              }
                            },
                            child: Container(
                              width: 64.w,
                              height: 64.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF0059AB),
                                  size: 38.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Bande bleue en bas avec courbe (seulement première page)
                    if (index == 0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipPath(
                          clipper: TopWaveClipper(),
                          child: Container(
                            width: double.infinity,
                            height: 120.h,
                            color: Color(0xFF0059AB),
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 25.h),
                              child: Text(
                                langProvider.translate('agency_name'),
                                style: getSourceSerifProStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                ),
              );
            },
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // Construction de la première page avec logo ARS et icônes selon le design
  Widget _buildFirstPageWithLogo(LanguageProvider langProvider) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Image onboarding1.png qui occupe tout l'écran - Relevée légèrement
          Positioned(
            top: -30.h,
            left: 0,
            right: 0,
            bottom: 30.h,
            child: Image.asset(
              'assets/images/onboarding1.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Erreur chargement image: $error');
                return Container(color: Colors.white);
              },
            ),
          ),
          
          // Bande bleue en bas avec courbe
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopWaveClipper(),
              child: Container(
                width: double.infinity,
                height: 120.h,
                color: Color(0xFF0059AB),
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 45.h),
                  child: Text(
                    langProvider.translate('agency_name'),
                    style: getSourceSerifProStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildARSLogoWithIcons() {
    // Dimensions réduites
    final containerWidth = 300.w;
    final containerHeight = 300.h;
    
    // Positions des icônes principales (kit médical au-dessus, couverts en dessous)
    final iconPositions = [
      Offset(0.w, -70.h),  // Au-dessus du R: Kit médical
      Offset(0.w, 70.h),   // En dessous du R: Couverts
    ];
    
    final iconData = [
      Icons.medical_services_outlined,  // Kit médical
      Icons.restaurant_menu,            // Couverts
    ];
    
    return SizedBox(
      width: containerWidth,
      height: containerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lignes pointillées depuis le cercle vers les icônes et les lettres
          CustomPaint(
            size: Size(containerWidth, containerHeight),
            painter: AllDottedLinesPainter(iconPositions),
          ),
          
          // Cercle bleu clair semi-transparent derrière le R
          Container(
            width: 170.w,
            height: 170.h,
            decoration: BoxDecoration(
              color: Color(0xFF0059AB).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
          
          // Logo ARS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lettre A
              _buildLetterA(),
              SizedBox(width: 12.w),
              // Lettre R (au centre avec cercle)
              _buildLetterR(),
              SizedBox(width: 12.w),
              // Lettre S
              _buildLetterS(),
            ],
          ),
          
          // Icône kit médical au-dessus du R
          Positioned(
            left: (containerWidth / 2) - 25.w,
            top: (containerHeight / 2) - 95.h,
            child: _buildIconCircle(iconData[0]),
          ),
          
          // Icône couverts en dessous du R
          Positioned(
            left: (containerWidth / 2) - 25.w,
            top: (containerHeight / 2) + 45.h,
            child: _buildIconCircle(iconData[1]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIconCircle(IconData icon) {
    return SizedBox(
      width: 50.w,
      height: 50.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle en pointillés
          CustomPaint(
            size: Size(50.w, 50.h),
            painter: DottedCirclePainter(),
          ),
          // Icône
          Icon(
            icon,
            color: Color(0xFF0059AB),
            size: 24.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildLetterA() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'A',
          style: getSourceSerifProStyle(
            fontSize: 70.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0059AB),
          ),
        ),
        // Icône de personne avec fourchette et couteau
        Positioned(
          bottom: 15.h,
          child: Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildLetterR() {
    return Text(
      'R',
      style: getSourceSerifProStyle(
        fontSize: 70.sp,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0059AB),
      ),
    );
  }

  Widget _buildLetterS() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'S',
          style: getSourceSerifProStyle(
            fontSize: 70.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0059AB),
          ),
        ),
        // Lignes horizontales blanches dans le S
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 30.w, height: 2.h, color: Colors.white),
            SizedBox(height: 8.h),
            Container(width: 30.w, height: 2.h, color: Colors.white),
            SizedBox(height: 8.h),
            Container(width: 30.w, height: 2.h, color: Colors.white),
          ],
        ),
      ],
    );
  }
}

// Painter pour cercle en pointillés
class DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF0059AB)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    
    // Dessiner un cercle en pointillés
    final dashWidth = 4.0;
    final dashSpace = 3.0;
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final angleStep = (2 * math.pi) / dashCount;
    
    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * angleStep;
      final endAngle = startAngle + (dashWidth / radius);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter pour toutes les lignes pointillées
class AllDottedLinesPainter extends CustomPainter {
  final List<Offset> iconPositions;
  
  AllDottedLinesPainter(this.iconPositions);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF0059AB)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final circleRadius = 85.0; // Rayon du cercle bleu (ajusté pour 170.w/170.h)
    
    // Dessiner une ligne pointillée pour chaque icône
    for (final iconPos in iconPositions) {
      // Calculer le point de départ sur le bord du cercle
      final dx = iconPos.dx;
      final dy = iconPos.dy;
      final angle = math.atan2(dy, dx);
      
      final startX = centerX + math.cos(angle) * circleRadius;
      final startY = centerY + math.sin(angle) * circleRadius;
      
      // Point d'arrivée (centre de l'icône)
      final endX = centerX + iconPos.dx;
      final endY = centerY + iconPos.dy;
      
      // Dessiner une ligne pointillée vers l'icône
      _drawDottedLine(canvas, paint, startX, startY, endX, endY);
      
      // Lignes vers les lettres A et S (horizontalement depuis le cercle)
      if (iconPos.dx == 0) {
        // Ligne vers A (gauche)
        final leftStartX = centerX - circleRadius;
        final leftStartY = centerY;
        final leftEndX = centerX - 60.w;
        final leftEndY = centerY;
        _drawDottedLine(canvas, paint, leftStartX, leftStartY, leftEndX, leftEndY);
        
        // Ligne vers S (droite)
        final rightStartX = centerX + circleRadius;
        final rightStartY = centerY;
        final rightEndX = centerX + 60.w;
        final rightEndY = centerY;
        _drawDottedLine(canvas, paint, rightStartX, rightStartY, rightEndX, rightEndY);
      }
    }
  }
  
  void _drawDottedLine(Canvas canvas, Paint paint, double startX, double startY, double endX, double endY) {
    final dashWidth = 5.0;
    final dashSpace = 3.0;
    double currentX = startX;
    double currentY = startY;
    
    final lineDx = endX - startX;
    final lineDy = endY - startY;
    final lineDistance = math.sqrt(lineDx * lineDx + lineDy * lineDy);
    final lineAngle = math.atan2(lineDy, lineDx);
    
    double currentDistance = 0;
    while (currentDistance < lineDistance) {
      final segmentLength = math.min(dashWidth, lineDistance - currentDistance);
      final endSegmentX = currentX + math.cos(lineAngle) * segmentLength;
      final endSegmentY = currentY + math.sin(lineAngle) * segmentLength;
      
      canvas.drawLine(
        Offset(currentX, currentY),
        Offset(endSegmentX, endSegmentY),
        paint,
      );
      
      currentDistance += dashWidth + dashSpace;
      currentX += math.cos(lineAngle) * (dashWidth + dashSpace);
      currentY += math.sin(lineAngle) * (dashWidth + dashSpace);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Clipper pour courbe concave (arrondie vers le bas) en haut de la bande bleue
class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Commence en haut à gauche
    path.moveTo(0, 0);
    
    // Courbe concave qui descend au milieu (comme un arc inversé)
    path.quadraticBezierTo(
      size.width / 2, 40.h,   // Point de contrôle au centre, descend de façon responsive
      size.width, 0,         // Retour au niveau initial à droite
    );
    
    // Ligne droite le long du côté droit
    path.lineTo(size.width, size.height);
    
    // Ligne du bas (de droite à gauche)
    path.lineTo(0, size.height);
    
    // Ferme le path
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

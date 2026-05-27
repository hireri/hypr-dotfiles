#!/usr/bin/env python3
import sys
import os
import shutil
import json
import tempfile
import subprocess
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QGridLayout, QScrollArea, QTabWidget, QFrame, QLabel, QCheckBox, QPushButton
)
from PyQt6.QtCore import Qt, QRectF, pyqtSignal, qInstallMessageHandler
from PyQt6.QtGui import QPixmap, QColor, QPainter, QPen, QGuiApplication, QPainterPath

ALLOW_TOKEN_BY_DEFAULT = "--allow-token" in sys.argv

HAS_GRIM = shutil.which("grim") is not None
HAS_HYPRCTL = shutil.which("hyprctl") is not None


def suppress_qt_messages(msg_type, context, msg_str):
    """Callback to silently discard all internal Qt, KDE, and system engine warnings."""
    pass


def make_rounded_pixmap(src_pixmap, width=220, height=130, radius=8):
    """Resizes and smoothly masks a pixmap into rounded corners."""
    if src_pixmap.isNull():
        return src_pixmap

    scaled = src_pixmap.scaled(
        width, height,
        Qt.AspectRatioMode.KeepAspectRatio,
        Qt.TransformationMode.SmoothTransformation
    )

    target = QPixmap(scaled.size())
    target.fill(Qt.GlobalColor.transparent)

    painter = QPainter(target)
    painter.setRenderHint(QPainter.RenderHint.Antialiasing, True)

    path = QPainterPath()
    path.addRoundedRect(QRectF(target.rect()), radius, radius)
    painter.setClipPath(path)

    painter.drawPixmap(0, 0, scaled)
    painter.end()
    return target


def make_placeholder(width, height, text, widget, radius=8):
    """Draws a clean, rounded dashed placeholder matching system colors."""
    palette = widget.palette()
    bg_color = palette.color(palette.ColorRole.Window)
    text_color = palette.color(palette.ColorRole.WindowText)

    pixmap = QPixmap(width, height)
    pixmap.fill(Qt.GlobalColor.transparent)

    painter = QPainter(pixmap)
    painter.setRenderHint(QPainter.RenderHint.Antialiasing, True)

    painter.setBrush(bg_color)
    painter.setPen(QPen(text_color, 1, Qt.PenStyle.DashLine))
    painter.drawRoundedRect(
        QRectF(5, 5, width - 10, height - 10), radius, radius)

    painter.setPen(text_color)
    font = painter.font()
    font.setPointSize(10)
    font.setBold(True)
    painter.setFont(font)
    painter.drawText(pixmap.rect(), Qt.AlignmentFlag.AlignCenter, text)
    painter.end()
    return pixmap


def parse_windows():
    """Parses active window list from portal environment, falling back to hyprctl."""
    env_str = os.environ.get("XDPH_WINDOW_SHARING_LIST", "")
    windows = []

    if env_str:
        rolling = env_str
        while rolling:
            try:
                id_sep = rolling.find("[HC>]")
                if id_sep == -1:
                    break
                id_str = rolling[:id_sep]
                class_sep = rolling.find("[HT>]")
                if class_sep == -1:
                    break
                class_str = rolling[id_sep + 5:class_sep]
                title_sep = rolling.find("[HE>]")
                if title_sep == -1:
                    break
                title_str = rolling[class_sep + 5:title_sep]
                window_sep = rolling.find("[HA>]")
                if window_sep == -1:
                    break

                windows.append(
                    {"id": id_str, "class": class_str, "title": title_str})
                rolling = rolling[window_sep + 5:]
            except Exception:
                break

    if not windows and HAS_HYPRCTL:
        try:
            res = subprocess.run(["hyprctl", "clients", "-j"],
                                 capture_output=True, text=True)
            if res.returncode == 0:
                for c in json.loads(res.stdout):
                    addr_hex = c.get("address", "0")
                    addr_str = str(int(addr_hex, 16) & 0xFFFFFFFF)
                    windows.append({"id": addr_str, "class": c.get(
                        "class", "Unknown"), "title": c.get("title", "No Title")})
        except Exception:
            pass

    return windows


class ScreenCard(QFrame):
    clicked = pyqtSignal(object)

    def __init__(self, screen, index, placeholder, parent=None):
        super().__init__(parent)
        self.screen = screen
        self.index = index
        self.setObjectName("Card")
        self.setCursor(Qt.CursorShape.PointingHandCursor)
        self.setFixedSize(240, 210)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(10, 10, 10, 10)

        self.preview_label = QLabel()
        self.preview_label.setFixedSize(220, 130)
        self.preview_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.preview_label.setPixmap(placeholder)
        layout.addWidget(self.preview_label)

        name = screen.name()
        geom = screen.geometry()
        self.info_label = QLabel(f"{name}\n{geom.width()}x{geom.height()}")
        self.info_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.info_label)

    def set_preview_image(self, file_path):
        pixmap = QPixmap(file_path)
        if not pixmap.isNull():
            self.preview_label.setPixmap(
                make_rounded_pixmap(pixmap, 220, 130, radius=8))

    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            self.clicked.emit(self)


class WindowCard(QFrame):
    clicked = pyqtSignal(object)

    def __init__(self, win_data, index, placeholder, parent=None):
        super().__init__(parent)
        self.win_id = win_data["id"]
        self.win_class = win_data["class"]
        self.win_title = win_data["title"]
        self.index = index
        self.setObjectName("Card")
        self.setCursor(Qt.CursorShape.PointingHandCursor)
        self.setFixedSize(240, 210)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(10, 10, 10, 10)

        self.preview_label = QLabel()
        self.preview_label.setFixedSize(220, 130)
        self.preview_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.preview_label.setPixmap(placeholder)
        layout.addWidget(self.preview_label)

        self.info_label = QLabel(self.win_class)
        self.info_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        font = self.info_label.font()
        font.setBold(True)
        self.info_label.setFont(font)
        layout.addWidget(self.info_label)

        self.title_label = QLabel()
        self.title_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        metrics = self.title_label.fontMetrics()
        elided = metrics.elidedText(
            self.win_title, Qt.TextElideMode.ElideRight, 220)
        self.title_label.setText(elided)
        layout.addWidget(self.title_label)

    def set_preview_image(self, file_path):
        pixmap = QPixmap(file_path)
        if not pixmap.isNull():
            self.preview_label.setPixmap(
                make_rounded_pixmap(pixmap, 220, 130, radius=8))

    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            self.clicked.emit(self)


class GridPage(QWidget):
    """Container widget that handles column wrapping and dynamic centering math."""

    def __init__(self, cards):
        super().__init__()
        self.cards = cards

        self.main_layout = QHBoxLayout(self)
        self.main_layout.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.main_layout.setContentsMargins(0, 0, 0, 0)

        self.grid_widget = QWidget()
        self.grid = QGridLayout(self.grid_widget)
        self.grid.setSpacing(10)
        self.grid.setContentsMargins(10, 10, 10, 10)
        self.main_layout.addWidget(self.grid_widget)

    def arrange(self, viewport_width):
        cols = max(1, (viewport_width - 20) // 250)

        for i in range(self.grid.count()):
            item = self.grid.itemAt(i)
            if item:
                self.grid.removeItem(item)

        for i, card in enumerate(self.cards):
            row = i // cols
            col = i % cols
            self.grid.addWidget(card, row, col, Qt.AlignmentFlag.AlignCenter)


class SharePickerWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Screencast Source Selector")
        self.resize(840, 580)
        self.setMinimumSize(540, 420)
        self.temp_files = []

        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(15, 15, 15, 15)

        self.tabs = QTabWidget()
        main_layout.addWidget(self.tabs)

        bottom_bar = QWidget()
        bottom_layout = QHBoxLayout(bottom_bar)
        self.restore_checkbox = QCheckBox("Allow a restore token")
        self.restore_checkbox.setChecked(ALLOW_TOKEN_BY_DEFAULT)
        bottom_layout.addWidget(self.restore_checkbox)
        bottom_layout.addStretch()

        cancel_btn = QPushButton("Cancel")
        cancel_btn.clicked.connect(self.on_cancel)
        bottom_layout.addWidget(cancel_btn)
        main_layout.addWidget(bottom_bar)

        screens = QGuiApplication.screens()
        screen_pixmaps = {}

        for s in screens:
            tmp_path = os.path.join(
                tempfile.gettempdir(), f"xdph_screen_{s.name()}.png")
            if HAS_GRIM:
                subprocess.run(["grim", "-o", s.name(), tmp_path],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                screen_pixmaps[s.name()] = QPixmap(tmp_path)
                self.temp_files.append(tmp_path)
            else:
                screen_pixmaps[s.name()] = QPixmap()

        clients = []
        if HAS_HYPRCTL:
            try:
                res = subprocess.run(
                    ["hyprctl", "clients", "-j"], capture_output=True, text=True)
                if res.returncode == 0:
                    clients = json.loads(res.stdout)
            except Exception:
                pass

        self.screen_scroll = QScrollArea()
        self.screen_scroll.setWidgetResizable(True)
        self.screen_scroll.setHorizontalScrollBarPolicy(
            Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
        self.screen_scroll.setAlignment(Qt.AlignmentFlag.AlignCenter)

        screen_cards_list = []
        for i, s in enumerate(screens):
            pix = screen_pixmaps.get(s.name(), QPixmap())
            placeholder = make_placeholder(220, 130, f"Screen {i}", self)

            card = ScreenCard(s, i, placeholder)
            card.clicked.connect(self.select_screen_card)

            if not pix.isNull():
                card.preview_label.setPixmap(
                    make_rounded_pixmap(pix, 220, 130, radius=8))

            screen_cards_list.append(card)

        self.screen_page = GridPage(screen_cards_list)
        self.screen_scroll.setWidget(self.screen_page)
        self.tabs.addTab(self.screen_scroll, "Screen")

        self.window_scroll = QScrollArea()
        self.window_scroll.setWidgetResizable(True)
        self.window_scroll.setHorizontalScrollBarPolicy(
            Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
        self.window_scroll.setAlignment(Qt.AlignmentFlag.AlignCenter)

        windows = parse_windows()
        window_cards_list = []

        for i, w in enumerate(windows):
            match = next((c for c in clients if c.get("class", "").lower(
            ) == w["class"].lower() or c.get("title", "").lower() == w["title"].lower()), None)
            win_pix = QPixmap()
            placeholder = make_placeholder(220, 130, w["class"], self)

            card = WindowCard(w, i, placeholder)
            card.clicked.connect(self.select_window_card)

            if match:
                x, y = match.get("at", [0, 0])
                width, height = match.get("size", [0, 0])

                for s in screens:
                    geom = s.geometry()
                    if geom.contains(x, y) and width > 0 and height > 0:
                        screen_pix = screen_pixmaps.get(s.name())
                        if screen_pix and not screen_pix.isNull():
                            win_pix = screen_pix.copy(
                                x - geom.x(), y - geom.y(), width, height)
                            break

            if not win_pix.isNull():
                card.preview_label.setPixmap(
                    make_rounded_pixmap(win_pix, 220, 130, radius=8))

            window_cards_list.append(card)

        self.window_page = GridPage(window_cards_list)
        self.window_scroll.setWidget(self.window_page)
        self.tabs.addTab(self.window_scroll, "Window")

        self.tabs.setCurrentIndex(0)

    def resizeEvent(self, event):
        """Standard resize hook to align grid page grids to centered horizontal columns."""
        super().resizeEvent(event)
        self.screen_page.arrange(self.screen_scroll.viewport().width())
        self.window_page.arrange(self.window_scroll.viewport().width())

    def select_screen_card(self, selectedCard):
        flag = "r" if self.restore_checkbox.isChecked() else ""
        print(f"[SELECTION]{flag}/screen:{selectedCard.screen.name()}")
        self.cleanup()
        sys.exit(0)

    def select_window_card(self, selectedCard):
        flag = "r" if self.restore_checkbox.isChecked() else ""
        print(f"[SELECTION]{flag}/window:{selectedCard.win_id}")
        self.cleanup()
        sys.exit(0)

    def cleanup(self):
        for path in self.temp_files:
            try:
                if os.path.exists(path):
                    os.remove(path)
            except Exception:
                pass

    def on_cancel(self):
        self.cleanup()
        sys.exit(1)

    def closeEvent(self, event):
        self.cleanup()
        sys.exit(1)


STYLESHEET = """
QFrame#Card {
    border-radius: 12px;
    background-color: transparent;
}
QFrame#Card:hover {
    background-color: palette(alternate-base);
}
"""


def main():
    qInstallMessageHandler(suppress_qt_messages)

    app = QApplication(sys.argv)
    app.setStyleSheet(STYLESHEET)
    window = SharePickerWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
